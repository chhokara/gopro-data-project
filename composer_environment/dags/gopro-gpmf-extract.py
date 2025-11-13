from __future__ import annotations
import base64
import json
from datetime import datetime, timedelta

from airflow import DAG
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.sensors.pubsub import PubSubPullSensor
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
    dag_id="gopro_gpmf_extract_v1",
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    default_args=DEFAULT_ARGS,
    tags=["gopro", "gpmf", "extraction", "gcs", "pubsub"],
) as dag:

    wait_for_event = PubSubPullSensor(
        task_id="wait_for_gcs_event",
        project_id=APP_PROJECT_ID,
        subscription=PUBSUB_SUBSCRIPTION,
        ack_messages=True,
        max_messages=1,
        poke_interval=20,
        timeout=60 * 10,
    )

    def parse_gcs_event(ti, **_):
        pulled = ti.xcom_pull(task_ids="wait_for_gcs_event")
        if not pulled:
            raise ValueError("No Pub/Sub messages received.")
        msg = pulled[0]["message"]
        payload = json.loads(base64.b64decode(msg["data"]).decode("utf-8"))

        bucket = payload["bucket"]
        name = payload["name"]

        if not bucket or not name:
            raise ValueError("Invalid GCS event data.")

        if bucket != RAW_BUCKET:
            print("Skipping non-raw bucket event.")
            ti.xcom_push(key="skip", value=True)
            return

        ti.xcom_push(key="bucket", value=bucket)
        ti.xcom_push(key="name", value=name)

    parse_event = PythonOperator(
        task_id="parse_gcs_event",
        python_callable=parse_gcs_event,
    )

    run_gpmf_extraction = KubernetesPodOperator(
        task_id="run_gpmf_extraction",
        name="gpmf-extract",
        namespace="default",
        image=CONTAINER_IMAGE,
        image_pull_policy="IfNotPresent",
        is_delete_operator_pod=True,
        env_vars={
            "RAW_BUCKET": "{{ ti.xcom_pull('parse_gcs_event', key='bucket')}}",
            "CURATED_BUCKET": CURATED_BUCKET,
            "OBJECT_NAME": "{{ ti.xcom_pull('parse_gcs_event', key='name')}}",
            "OUT_PREFIX": OUT_PREFIX,
        },
        get_logs=True,
    )

    wait_for_event >> parse_event >> run_gpmf_extraction
