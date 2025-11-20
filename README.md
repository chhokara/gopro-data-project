# GoPro Telemetry Analysis

## Project Overview

This project implements a fully serverless data pipeline on Google Cloud Platform (GCP) to extract and visualize GPMF telemetry data from GoPro videos. When a raw .mp4 file is uploaded to a Google Cloud Storage (GCS) bucket, an Object Finalize event triggers Eventarc, which launches a Cloud Run Job running a custom ETL container. The job parses embedded GPS, accelerometer, and gyroscope data and writes the processed outputs into a curated GCS bucket. These curated datasets are then loaded into BigQuery for scalable querying and analysis. The telemetry is visualized in Grafana, which connects directly to BigQuery to provide rich time-series dashboards for speed, movement, and performance insights. The entire architecture is provisioned using Terraform, resulting in a cost-efficient, event-driven, and easily extensible system for future analytics and visualization enhancements.

## System Architecture

![System Architecture](assets/gcp.png)

## Technologies

- GoPro (GPMF Telemetry) – Source of raw video and sensor data
- Google Cloud Storage (GCS) – Raw and curated data storage
- Eventarc – Triggers ETL jobs on GCS object finalize events
- Cloud Run Jobs – Serverless execution of the ETL pipeline
- Artifact Registry – Stores the ETL Docker image
- BigQuery – Analytics warehouse for processed telemetry
- Grafana – Visualization layer for insights and metrics
- Docker – Containerization for the ETL application
- Terraform – Infrastructure as Code for provisioning all resources
