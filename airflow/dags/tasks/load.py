import logging

log = logging.getLogger(__name__)


def load_to_bigquery(**context):
    """
    Loads the Parquet files from the curated GCS bucket into the
    BigQuery raw dataset (raw.gps5, raw.accl, raw.gyro).
    """
    pass
