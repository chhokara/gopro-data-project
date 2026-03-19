FROM apache/airflow:2.10.1

# Install C++ build tools required to compile py-gpmf-parser from source
USER root
RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    git \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

USER airflow

# Install Airflow providers and dbt packages using the official Airflow constraints
# file to avoid pip dependency resolution conflicts
RUN pip install --no-cache-dir \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.10.1/constraints-3.12.txt" \
    apache-airflow-providers-google \
    astronomer-cosmos \
    dbt-bigquery

# Install py-gpmf-parser separately to avoid dependency resolution conflicts
RUN pip install --no-cache-dir \
    git+https://github.com/urbste/py-gpmf-parser.git
