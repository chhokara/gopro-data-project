with motion as (
    select * from {{ ref('int_motion') }}
)

select
    session_id,
    round(max(timestamp_s) - min(timestamp_s), 2)  as duration_s,
    count(*)                                        as total_samples,
    round(max(accel_magnitude_ms2), 4)              as peak_accel_ms2,
    round(avg(accel_magnitude_ms2), 4)              as avg_accel_ms2,
    round(max(gyro_magnitude_rads), 4)              as peak_gyro_rads,
    round(avg(gyro_magnitude_rads), 4)              as avg_gyro_rads
from motion
group by session_id
