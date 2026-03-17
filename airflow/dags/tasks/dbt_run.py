import logging

log = logging.getLogger(__name__)


def run_dbt(**context):
    """
    Triggers dbt transformations via Astronomer Cosmos to build
    Bronze -> Silver -> Gold medallion layers in BigQuery.
    """
    pass
