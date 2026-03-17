from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from tasks.constants import RAW_BUCKET
from tasks.dbt_run import run_dbt
from tasks.extract import extract_telemetry
from tasks.load import load_to_bigquery

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}

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
