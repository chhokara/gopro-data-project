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

# Install Airflow providers and dbt packages together
RUN pip install --no-cache-dir \
    apache-airflow-providers-google \
    astronomer-cosmos \
    dbt-bigquery

# Install py-gpmf-parser separately to avoid dependency resolution conflicts
RUN pip install --no-cache-dir \
    git+https://github.com/urbste/py-gpmf-parser.git
