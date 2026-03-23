{% set relation = adapter.get_relation(
    database='gopro-data-project',
    schema='raw',
    identifier='gps5'
) %}

{% if relation %}
with source as (
    select * from {{ source('raw', 'gps5') }}
)

select
    session_id,
    timestamp_s,
    latitude,
    longitude,
    altitude_m,
    speed_2d_ms,
    speed_3d_ms,
    speed_2d_ms * 3.6 as speed_2d_kmh,
    speed_3d_ms * 3.6 as speed_3d_kmh
from source

{% else %}
    {{ log("raw.gps5 does not exist yet — returning empty result", info=true) }}
    select
        cast(null as string)  as session_id,
        cast(null as float64) as timestamp_s,
        cast(null as float64) as latitude,
        cast(null as float64) as longitude,
        cast(null as float64) as altitude_m,
        cast(null as float64) as speed_2d_ms,
        cast(null as float64) as speed_3d_ms,
        cast(null as float64) as speed_2d_kmh,
        cast(null as float64) as speed_3d_kmh
    where false
{% endif %}
