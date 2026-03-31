from google.cloud import bigquery


def run_query(sql: str) -> list[dict]:
    bq_client = bigquery.Client()
    results = bq_client.query(sql).result()
    return [dict(row) for row in results]
