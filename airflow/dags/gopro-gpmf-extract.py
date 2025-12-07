from datetime import datetime, timedelta
import json
import base64

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.sensors.pubsub import PubSubPullSensor
from airflow.providers.google.cloud.operators.cloud_run import CloudRunExecuteJobOperator

PROJECT_ID = "gopro-data-project"
REGION = "us-central1"
CLOUD_RUN_JOB_NAME = "gopro-data-processor-job"
SUBSCRIPTION = "gopro-data-subscription"

RAW_BUCKET = "gopro-raw-data-bucket"
CURATED_BUCKET = "gopro-curated-data-bucket"

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}

with DAG(
    dag_id="gopro_gpmf_extract",
    start_date=datetime(2024, 1, 1),
    schedule_interval="* * * * *",
    catchup=False,
    default_args=default_args,
) as dag:
    wait_for_message = PubSubPullSensor(
        task_id="wait_for_pubsub_message",
        project_id=PROJECT_ID,
        subscription=SUBSCRIPTION,
        ack_messages=True,
        max_messages=1,
        poke_interval=10,
        timeout=60*5,
        gcp_conn_id="google_cloud_default",
    )

    def extract_gcs_message_from_pubsub(**context):
        ti = context['ti']
        messages = ti.xcom_pull(task_ids="wait_for_pubsub_message")

        msg = messages[0]
        data_b64 = msg["message"]["data"]

        payload = base64.b64decode(data_b64).decode('utf-8')

        try:
            data = json.loads(payload)
        except json.JSONDecodeError:
            data = {"raw_payload": payload}

        bucket = data.get("bucket")
        object_name = data.get("object_name")

        ti.xcom_push(key='bucket', value=bucket)
        ti.xcom_push(key='object_name', value=object_name)

    parse_message = PythonOperator(
        task_id="parse_pubsub_message",
        python_callable=extract_gcs_message_from_pubsub,
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
                            "value": "{{ ti.xcom_pull(task_ids='parse_pubsub_message', key='bucket') }}",
                        },
                        {
                            "name": "OBJECT_NAME",
                            "value": "{{ ti.xcom_pull(task_ids='parse_pubsub_message', key='object_name') }}",
                        },
                    ]
                }
            ]
        }
    )

    wait_for_message >> parse_message >> run_gpmf_extraction_job
