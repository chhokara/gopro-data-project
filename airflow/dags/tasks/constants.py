PROJECT_ID = "gopro-data-project"
REGION = "us-central1"
RAW_BUCKET = "gopro-raw-data-bucket"
CURATED_BUCKET = "gopro-curated-data-bucket"
BQ_RAW_DATASET = "raw"

# Column names per GPMF stream spec
# GPS5: latitude (deg), longitude (deg), altitude (m WGS-84), 2D speed (m/s), 3D speed (m/s)
# ACCL: x, y, z acceleration (m/s²)
# GYRO: x, y, z angular velocity (rad/s)
STREAMS = {
    "GPS5": ["latitude", "longitude", "altitude_m", "speed_2d_ms", "speed_3d_ms"],
    "ACCL": ["accel_x_ms2", "accel_y_ms2", "accel_z_ms2"],
    "GYRO": ["gyro_x_rads", "gyro_y_rads", "gyro_z_rads"],
}
