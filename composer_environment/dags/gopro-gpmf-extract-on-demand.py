from __future__ import annotations
from datetime import datetime, timedelta

from airflow import DAG
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator

# Trigger
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
    def prepare_on_demand_run(ti, dag_run=None):
        conf = dag_run.conf if dag_run else {}

        bucket = conf.get("bucket", RAW_BUCKET)
        name = conf.get("name")
        out_prefix = conf.get("out_prefix", OUT_PREFIX)

        if not name:
            raise ValueError("Parameter 'name' is required.")

        ti.xcom_push(key="bucket", value=bucket)
        ti.xcom_push(key="name", value=name)
        ti.xcom_push(key="out_prefix", value=out_prefix)

    prepare_task = PythonOperator(
        task_id="prepare_on_demand_run",
        python_callable=prepare_on_demand_run,
    )

    run_gpmf_extraction = KubernetesPodOperator(
        task_id="run_gpmf_extraction_on_demand",
        name="gpmf-extract-on-demand",
        namespace="composer-user-workloads",
        config_file="/home/airflow/composer_kube_config",
        image=CONTAINER_IMAGE,
        image_pull_policy="IfNotPresent",
        is_delete_operator_pod=True,
        env_vars={
            "RAW_BUCKET": "{{ ti.xcom_pull('prepare_on_demand_run', key='bucket')}}",
            "CURATED_BUCKET": CURATED_BUCKET,
            "OBJECT_NAME": "{{ ti.xcom_pull('prepare_on_demand_run', key='name')}}",
            "OUT_PREFIX": "{{ ti.xcom_pull('prepare_on_demand_run', key='out_prefix')}}",
        },
        get_logs=True,
    )

    prepare_task >> run_gpmf_extraction
