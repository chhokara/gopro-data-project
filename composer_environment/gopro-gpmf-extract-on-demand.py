from __future__ import annotations
from datetime import datetime, timedelta

from airflow import DAG
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator


# General Config
APP_PROJECT_ID = Variable.get(
    "APP_PROJECT_ID", default_var="gopro-data-project")
RAW_BUCKET = Variable.get(
    "RAW_BUCKET", default_var="gopro-raw-data-bucket")
CURATED_BUCKET = Variable.get(
    "CURATED_BUCKET", default_var="gopro-curated-data-bucket")
PUBSUB_SUBSCRIPTION = Variable.get(
    "PUBSUB_SUBSCRIPTION", default_var="gopro-data-subscription")
REGION = Variable.get(
    "REGION", default_var="us-central1")
OUT_PREFIX = Variable.get(
    "OUT_PREFIX", default_var="gpmf/")
DEFAULT_ARGS = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=3),
}

# Artifact Registry Container
AR_REPO = Variable.get(
    "AR_REPO", default_var="gopro-artifact-repo")
AR_IMAGE = Variable.get(
    "AR_IMAGE", default_var="gpmf-extractor")
AR_TAG = Variable.get(
    "AR_TAG", default_var="v1")
CONTAINER_IMAGE = f"{REGION}-docker.pkg.dev/{APP_PROJECT_ID}/{AR_REPO}/{AR_IMAGE}:{AR_TAG}"


with DAG(
    dag_id="gopro_gpmf_extract_on_demand_v1",
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    default_args=DEFAULT_ARGS,
    tags=["gopro", "gpmf", "extraction", "gcs", "on_demand"],
) as dag:
    pass
