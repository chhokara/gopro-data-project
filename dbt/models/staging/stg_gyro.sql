{% set relation = adapter.get_relation(
    database='gopro-data-project',
    schema='raw',
    identifier='gyro'
) %}

{% if relation %}
with source as (
    select * from {{ source('raw', 'gyro') }}
)

select
    session_id,
    timestamp_s,
    gyro_x_rads,
    gyro_y_rads,
    gyro_z_rads,
    sqrt(
        pow(gyro_x_rads, 2) +
        pow(gyro_y_rads, 2) +
        pow(gyro_z_rads, 2)
    ) as gyro_magnitude_rads
from source

{% else %}
    {{ log("raw.gyro does not exist yet — returning empty result", info=true) }}
    select
        cast(null as string)  as session_id,
        cast(null as float64) as timestamp_s,
        cast(null as float64) as gyro_x_rads,
        cast(null as float64) as gyro_y_rads,
        cast(null as float64) as gyro_z_rads,
        cast(null as float64) as gyro_magnitude_rads
    limit 0
{% endif %}
