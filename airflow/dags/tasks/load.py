import logging
from google.cloud import bigquery
from tasks.constants import BQ_RAW_DATASET, CURATED_BUCKET, PROJECT_ID

log = logging.getLogger(__name__)


def load_to_bigquery(**context):
    """
    Loads the Parquet files from the curated GCS bucket into the
    BigQuery raw dataset (raw.gps5, raw.accl, raw.gyro).
    """
    session_id = context["ti"].xcom_pull(
        task_ids="extract_telemetry", key="session_id")
    log.info("Loading session %s into BigQuery...", session_id)

    bq_client = bigquery.Client(project=PROJECT_ID)

    stream_tables = {
        "GPS5": "gps5",
        "ACCL": "accl",
        "GYRO": "gyro"
    }

    for stream_key, table_suffix in stream_tables.items():
        uri = f"gs://{CURATED_BUCKET}/{session_id}/{stream_key.lower()}.parquet"
        table_ref = f"{PROJECT_ID}.{BQ_RAW_DATASET}.{table_suffix}"

        job_config = bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.PARQUET,
            write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
            autodetect=True
        )

        try:
            load_job = bq_client.load_table_from_uri(
                uri, table_ref, job_config=job_config)
            load_job.result()
            log.info("Loaded %s -> %s", uri, table_ref)
        except Exception as e:
            log.warning(
                "Skipping %s — file not found or load failed: %s", uri, e)
