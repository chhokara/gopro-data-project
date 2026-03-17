import logging
import os
import tempfile
from datetime import datetime, timedelta

import pandas as pd
from google.cloud import storage
from py_gpmf_parser.gopro_telemetry_extractor import GoProTelemetryExtractor

from airflow import DAG
from airflow.operators.python import PythonOperator

log = logging.getLogger(__name__)

PROJECT_ID = "gopro-data-project"
REGION = "us-central1"
RAW_BUCKET = "gopro-raw-data-bucket"
CURATED_BUCKET = "gopro-curated-data-bucket"
BQ_RAW_DATASET = "raw"

# Column names per GPMF stream spec
# GPS5: latitude (deg), longitude (deg), altitude (m WGS-84), 2D speed (m/s), 3D speed (m/s)
# ACCL: x, y, z acceleration (m/s²)
# GYRO: x, y, z angular velocity (rad/s)
STREAMS = {
    "GPS5": ["latitude", "longitude", "altitude_m", "speed_2d_ms", "speed_3d_ms"],
    "ACCL": ["accel_x_ms2", "accel_y_ms2", "accel_z_ms2"],
    "GYRO": ["gyro_x_rads", "gyro_y_rads", "gyro_z_rads"],
}

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}


def extract_telemetry(**context):
    """
    Downloads the raw .mp4 from GCS and extracts GPS, ACCL, and GYRO
    streams using py-gpmf-parser. Writes one Parquet file per stream
    to the curated GCS bucket.
    """
    params = context["params"]
    bucket_name = params["bucket"]
    object_name = params["object_name"]

    if not object_name:
        raise ValueError("object_name param is required (e.g. 'GH010001.MP4')")

    # Derive a session ID from the filename (strip extension)
    session_id = os.path.splitext(os.path.basename(object_name))[0]
    log.info("Session ID: %s", session_id)

    gcs_client = storage.Client()

    # Download .mp4 to an ephemeral temp file
    with tempfile.NamedTemporaryFile(suffix=".mp4", delete=False) as tmp:
        tmp_path = tmp.name

    try:
        log.info("Downloading gs://%s/%s -> %s", bucket_name, object_name, tmp_path)
        blob = gcs_client.bucket(bucket_name).blob(object_name)
        blob.download_to_filename(tmp_path)
        log.info("Download complete (%s bytes). Extracting telemetry...", os.path.getsize(tmp_path))

        extractor = GoProTelemetryExtractor(tmp_path)
        extractor.open_source()

        curated_bucket = gcs_client.bucket(CURATED_BUCKET)

        for stream_key, columns in STREAMS.items():
            data, timestamps = extractor.extract_data(stream_key)

            df = pd.DataFrame(data, columns=columns)
            df.insert(0, "timestamp_s", timestamps)
            df.insert(0, "session_id", session_id)

            dest_path = f"{session_id}/{stream_key.lower()}.parquet"
            curated_bucket.blob(dest_path).upload_from_string(
                df.to_parquet(index=False),
                content_type="application/octet-stream",
            )
            log.info("Uploaded %d rows -> gs://%s/%s", len(df), CURATED_BUCKET, dest_path)

        extractor.close_source()

    finally:
        os.unlink(tmp_path)
        log.info("Deleted temp file %s", tmp_path)

    # Pass session_id to downstream tasks via XCom
    context["ti"].xcom_push(key="session_id", value=session_id)


def load_to_bigquery(**context):
    """
    Loads the Parquet files from the curated GCS bucket into the
    BigQuery raw dataset (raw.gps5, raw.accl, raw.gyro).
    """
    pass


def run_dbt(**context):
    """
    Triggers dbt transformations via Astronomer Cosmos to build
    Bronze -> Silver -> Gold medallion layers in BigQuery.
    """
    pass


with DAG(
    dag_id="gopro_pipeline",
    description="Extracts GoPro GPMF telemetry and transforms it through the medallion architecture.",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    default_args=default_args,
    params={
        "bucket": RAW_BUCKET,
        "object_name": "",
    },
) as dag:

    extract = PythonOperator(
        task_id="extract_telemetry",
        python_callable=extract_telemetry,
    )

    load = PythonOperator(
        task_id="load_to_bigquery",
        python_callable=load_to_bigquery,
    )

    dbt = PythonOperator(
        task_id="run_dbt",
        python_callable=run_dbt,
    )

    extract >> load >> dbt
