# Docker Swarm Ansible Deployment Example

This project is a web application whose purpose is to view and maintain statistics/reports. It provides tools for data collection from a variety sources. It is a copy of the repository in GitLab but the application code has been removed and only the DevOps configuration is shown. This is for privacy and security reasons.

## 1. Application Information

This is a Docker Swarm microservice web application made up of the docker services listed below:

| Service Name | Purpose  |
| ---          | ---      |
| app     | The primary app, built with Ruby on Rails.  |
| primary-db       | Primary database used by app service. Postgres database.   |
| replica-db       | Replica database used by app service. Postgres database.        |
| delayed_jobs |  Handles user uploaded data and updates the primary database. |
| python_jobs | Python scripts that handles more data ingestion from various sources. Used only on by devs/administrators, not end-users.  |
| shibboleth | SSO service |
| ezpaarse | an external service we forked. Used to ingest/process proxy logs. Accesses proxy logs dumped into asg02 file share. Visit https://github.com/ezpaarse-project/ezpaarse |
| ezpaarse_db | an external service required by ezpaarse service. MongoDB instance. |
| jenkins | Job manager used to schedule cron tasks to import data and run ezpaarse. |
| prometheus | Open-source third-party monitoring. Used to send alerts. Visit https://hub.docker.com/r/prom/prometheus for more info.  |
| alertmanager-1 | The Alertmanager handles alerts sent by client applications such as the Prometheus server. It takes care of deduplicating, grouping, and routing them to the correct receiver integrations⁠ such as email, PagerDuty, OpsGenie, or many other mechanisms⁠ thanks to the webhook receiver. It also takes care of silencing and inhibition of alerts. Visit https://hub.docker.com/r/prom/alertmanager for more info. |
| alertmanager-2 | Same as alertmanager-1. |
| grafana | The open-source platform for monitoring and observability. Visit https://github.com/grafana/grafana for more info. | 
| grafana-db | Postgres db required by Grafana.  |
| node-exporter | Prometheus exporter for hardware and OS metrics exposed by *NIX kernels, written in Go with pluggable metric collectors. Visit https://hub.docker.com/r/prom/node-exporter for more info. |
| postgres-exporter | Prometheus exporter for sending postgres information. Visit https://github.com/prometheus-community/postgres_exporter for more info. |

![alt text](img/example-flowchart.png "Application Flowchart")

## 2. DevOps Information

- Gitlab: The main runner for the CI/CD pipeline. Sets environment variables to create separate staging and production deployments.
- Ansible: Configuration management tool used to 