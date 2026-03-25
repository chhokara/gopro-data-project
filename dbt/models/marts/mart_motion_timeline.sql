with motion as (
    select * from {{ ref('int_motion') }}
)

select
    session_id,
    timestamp_s,
    accel_magnitude_ms2,
    gyro_magnitude_rads
from motion
order by session_id, timestamp_s
