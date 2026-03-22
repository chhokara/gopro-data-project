import logging
import os
import tempfile

import pandas as pd
from google.cloud import storage
from py_gpmf_parser.gopro_telemetry_extractor import GoProTelemetryExtractor

from tasks.constants import CURATED_BUCKET, STREAMS

log = logging.getLogger(__name__)


def extract_telemetry(**context):
    """
    Downloads the raw .mp4 from GCS and extracts GPS, ACCL, and GYRO
    streams using py-gpmf-parser. Writes one Parquet file per stream
    to the curated GCS bucket.
    """
    # dag_run.conf is set when the DAG is triggered externally (e.g. via REST API
    # or Pub/Sub). context["params"] is used as a fallback for manual UI triggers.
    conf = context["dag_run"].conf or {}
    bucket_name = conf.get("bucket") or context["params"]["bucket"]
    object_name = conf.get("object_name") or context["params"]["object_name"]

    if not object_name:
        raise ValueError("object_name is required — pass it via dag_run.conf or the Trigger DAG UI")

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

            if len(data) == 0:
                log.warning("No data found for stream %s — skipping", stream_key)
                continue

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
