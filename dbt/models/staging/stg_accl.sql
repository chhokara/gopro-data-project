{% set relation = adapter.get_relation(
    database='gopro-data-project',
    schema='raw',
    identifier='accl'
) %}

{% if relation %}
with source as (
    select * from {{ source('raw', 'accl') }}
)

select
    session_id,
    timestamp_s,
    accel_x_ms2,
    accel_y_ms2,
    accel_z_ms2,
    sqrt(
        pow(accel_x_ms2, 2) +
        pow(accel_y_ms2, 2) +
        pow(accel_z_ms2, 2)
    ) as accel_magnitude_ms2
from source

{% else %}
    {{ log("raw.accl does not exist yet — returning empty result", info=true) }}
    select
        cast(null as string)  as session_id,
        cast(null as float64) as timestamp_s,
        cast(null as float64) as accel_x_ms2,
        cast(null as float64) as accel_y_ms2,
        cast(null as float64) as accel_z_ms2,
        cast(null as float64) as accel_magnitude_ms2
    where false
{% endif %}
