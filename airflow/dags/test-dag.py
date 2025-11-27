from datetime import datetime, timedelta
import json

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.sensors.pubsub import PubSubPullSensor
from airflow.providers.google.cloud.operators.gcs import GCSListObjectsOperator

PROJECT_ID = 'gopro-data-project'
SUBSCRIPTION = 'projects/gopro-data-project/subscriptions/gopro-data-subscription'
RAW_BUCKET = 'gopro-raw-data-bucket'
CURATED_BUCKET = 'gopro-curated-data-bucket'

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    dag_id='gopro_pubsub_gcs_demo',
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    default_args=default_args,
) as dag:
    wait_for_message = PubSubPullSensor(
        task_id='wait_for_pubsub_message',
        project_id=PROJECT_ID,
        subscription=SUBSCRIPTION,
        ack_messages=True,
        max_messages=1,
        poke_interval=10,
        timeout=60 * 5,
        gcp_conn_id='google_cloud_default',
    )

    def process_pubsub_message(**context):
        messages = context["ti"].xcom_pull(task_ids='wait_for_pubsub_message')
        msg = messages[0]
        payload = msg.message.data.decode('utf-8')

        try:
            data = json.loads(payload)
        except json.JSONDecodeError:
            data = {'raw_payload': payload}

        context['ti'].xcom_push(key='parsed_payload', value=data)

    parse_message = PythonOperator(
        task_id='parse_pubsub_message',
        python_callable=process_pubsub_message,
        provide_context=True,
    )

    list_curated_objects = GCSListObjectsOperator(
        task_id='list_curated_gcs_objects',
        bucket=CURATED_BUCKET,
        gcp_conn_id='google_cloud_default',
    )

    wait_for_message >> parse_message >> list_curated_objects
