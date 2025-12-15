from datetime import datetime, timedelta

from airflow import DAG
from airflow.models.param import Param
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.cloud_run import CloudRunExecuteJobOperator

PROJECT_ID = "gopro-data-project"
REGION = "us-central1"
CLOUD_RUN_JOB_NAME = "gopro-data-processor-job"

RAW_BUCKET = "gopro-raw-data-bucket"

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}


def prepare_inputs(**context):
    dag_run = context.get("dag_run")
    conf = dag_run.conf if dag_run else {}
    params = context.get("params", {})

    bucket = conf.get("bucket") or params.get("bucket") or RAW_BUCKET
    object_name = conf.get("object_name") or params.get("object_name")

    if not object_name:
        raise ValueError(
            "Provide object_name in DAG run config to point at an existing file.")

    ti = context["ti"]
    ti.xcom_push(key="bucket", value=bucket)
    ti.xcom_push(key="object_name", value=object_name)


with DAG(
    dag_id="gopro_gpmf_extract_manual",
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    default_args=default_args,
    description="On-demand trigger to process an existing GoPro video already in raw GCS.",
    # Defining Params surfaces a form in the UI when triggering the DAG.
    params={
        "bucket": Param(
            default=RAW_BUCKET,
            type="string",
            description="GCS bucket containing the raw GoPro file.",
        ),
        "object_name": Param(
            default="",
            type="string",
            description="Path of the existing GoPro file in the bucket (required).",
        ),
    },
) as dag:
    parse_conf = PythonOperator(
        task_id="prepare_inputs",
        python_callable=prepare_inputs,
        provide_context=True,
    )

    run_gpmf_extraction_job = CloudRunExecuteJobOperator(
        task_id="run_gpmf_extraction_job",
        project_id=PROJECT_ID,
        region=REGION,
        job_name=CLOUD_RUN_JOB_NAME,
        gcp_conn_id="google_cloud_default",
        overrides={
            "container_overrides": [
                {
                    "env": [
                        {
                            "name": "RAW_BUCKET",
                            "value": "{{ ti.xcom_pull(task_ids='prepare_inputs', key='bucket') }}",
                        },
                        {
                            "name": "OBJECT_NAME",
                            "value": "{{ ti.xcom_pull(task_ids='prepare_inputs', key='object_name') }}",
                        },
                    ]
                }
            ]
        },
    )

    parse_conf >> run_gpmf_extraction_job
