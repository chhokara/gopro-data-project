import functions_framework
import os
import requests


@functions_framework.cloud_event
def trigger_pipeline(cloud_event) -> None:
    """
    Triggered by a GCS object finalization event on the raw bucket.
    Calls the Airflow REST API to kick off the gopro_pipeline DAG.
    """
    data = cloud_event.data
    bucket = data["bucket"]
    object_name = data["name"]

    # Only process .mp4 files
    if not object_name.lower().endswith(".mp4"):
        print(f"Skipping non-MP4 file: {object_name}")
        return

    airflow_url = os.environ["AIRFLOW_URL"]
    dag_id = os.environ["AIRFLOW_DAG_ID"]
    username = os.environ["AIRFLOW_USERNAME"]
    password = os.environ["AIRFLOW_PASSWORD"]

    endpoint = f"{airflow_url}/api/v1/dags/{dag_id}/dagRuns"
    payload = {
        "conf": {
            "bucket": bucket,
            "object_name": object_name,
        }
    }

    response = requests.post(
        endpoint,
        json=payload,
        auth=(username, password),
        headers={"Content-Type": "application/json"},
    )
    response.raise_for_status()
    print(f"Triggered DAG run for {object_name}: {response.json()}")
