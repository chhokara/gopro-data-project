from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from cosmos import DbtTaskGroup, ExecutionConfig, ProfileConfig, ProjectConfig

from tasks.constants import RAW_BUCKET
from tasks.extract import extract_telemetry
from tasks.load import load_to_bigquery

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}

profile_config = ProfileConfig(
    profile_name="gopro_data",
    target_name="dev",
    profiles_yml_filepath="/opt/airflow/dbt/profiles.yml",
)

project_config = ProjectConfig(
    dbt_project_path="/opt/airflow/dbt",
)

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

    dbt = DbtTaskGroup(
        group_id="run_dbt",
        project_config=project_config,
        profile_config=profile_config,
        execution_config=ExecutionConfig(
            dbt_executable_path="/home/airflow/.local/bin/dbt",
        ),
    )

    extract >> load >> dbt
