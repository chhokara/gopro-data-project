with accl as (
    select * from {{ ref('stg_accl') }}
),

gyro as (
    select * from {{ ref('stg_gyro') }}
)

select
    accl.session_id,
    accl.timestamp_s,
    accl.accel_x_ms2,
    accl.accel_y_ms2,
    accl.accel_z_ms2,
    accl.accel_magnitude_ms2,
    gyro.gyro_x_rads,
    gyro.gyro_y_rads,
    gyro.gyro_z_rads,
    gyro.gyro_magnitude_rads
from accl
left join gyro
    on accl.session_id = gyro.session_id
    and accl.timestamp_s = gyro.timestamp_s
