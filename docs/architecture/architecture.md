# Production Observability Platform on Amazon EKS

## Objective

Build a production-style observability platform on Amazon EKS covering:

- Metrics
- Logs
- Dashboards
- Alerting
- Kubernetes workload monitoring

## Target Stack

- AWS
- Terraform
- Amazon EKS
- Kubernetes
- Helm
- Prometheus
- Grafana
- Alertmanager
- Loki
- Promtail
- kube-state-metrics
- Node Exporter
- Metrics Server
- GitHub / Git
- GitOps where appropriate

## High-Level Architecture

```text
AWS
 |
 VPC
 |
 EKS
 |
 +-- Application Workloads
 |
 +-- Kubernetes Metrics
 |    +-- Metrics Server
 |    +-- kube-state-metrics
 |    +-- Node Exporter
 |
 +-- Observability
      +-- Prometheus
      +-- Grafana
      +-- Alertmanager
      +-- Loki
      +-- Promtail

Metrics:
Workloads / Kubernetes / Nodes -> Prometheus -> Grafana

Logs:
Containers -> Promtail -> Loki -> Grafana

Alerts:
Prometheus -> Alertmanager

Infrastructure Principles
Infrastructure is provisioned using Terraform.
Kubernetes workloads are deployed declaratively.
Helm is used for complex third-party observability components.
AWS credentials are not stored in the repository.
Terraform state is not committed to Git.
Kubernetes workloads use resource requests and limits.
The platform should be reproducible from a clean environment.
AWS resources will be destroyed after project completion.
Security Principles
Prefer IAM roles over static credentials.
Keep worker nodes in private subnets where practical.
Restrict network access through security groups and Kubernetes policies.
Avoid committing secrets to Git.
Use Kubernetes RBAC for access control.
Reliability Principles
Health checks for workloads.
Resource management.
Monitoring of Kubernetes objects and nodes.
Alerting for meaningful failure conditions.
Persistent storage where required by observability components.
Cost Strategy

This is a portfolio and learning environment.

The infrastructure will therefore prioritize:

Production-style architecture.
Reasonable AWS cost.
Resource visibility.
Safe teardown using Terraform.

Expensive production-scale services will not be introduced unless they provide meaningful learning value.

Planned Phases
Architecture and project setup
Terraform and EKS infrastructure
Helm fundamentals and deployment
Prometheus
Grafana
kube-state-metrics and Node Exporter
Loki and Promtail
Alertmanager and alert rules
Application and Kubernetes monitoring
Failure and alert testing
Documentation and screenshots
GitHub finalization and release
Portfolio update
Terraform destroy and AWS cleanup
