# EKS Observability Platform

A production-oriented Kubernetes observability platform built on **Amazon EKS**, using Terraform for infrastructure and Helm for observability components.

The platform provides centralized **metrics, logs, dashboards, alerting, and persistent log storage** for workloads running inside Kubernetes.

---

## Architecture

```text
                         AWS
                          │
                    ┌─────▼─────┐
                    │    VPC    │
                    │ Terraform │
                    └─────┬─────┘
                          │
                    ┌─────▼─────┐
                    │    EKS    │
                    │ Kubernetes│
                    └─────┬─────┘
                          │
          ┌───────────────┼────────────────┐
          │               │                │
          ▼               ▼                ▼
     Prometheus         Alloy            EBS CSI
       Metrics           Logs             Storage
          │               │                │
          │               ▼                ▼
          │              Loki          gp3 / EBS
          │               │
          └───────┬───────┘
                  ▼
              ┌───────┐
              │Grafana│
              └───┬───┘
                  │
        ┌─────────┼──────────┐
        ▼         ▼          ▼
     Metrics     Logs      Alerts
     Dashboard   Explore   Rules
```

---

## Project Goals

The platform was designed to solve common Kubernetes observability requirements:

- Collect cluster and node metrics
- Collect Kubernetes workload logs
- Store logs persistently
- Visualize metrics and logs through Grafana
- Create operational alerts
- Manage infrastructure through Terraform
- Manage Kubernetes applications through Helm
- Manage Grafana dashboards as code
- Keep infrastructure configuration reproducible through Git

---

## Technology Stack

| Area | Technology |
|---|---|
| Cloud | AWS |
| Kubernetes | Amazon EKS |
| Infrastructure as Code | Terraform |
| Package Management | Helm |
| Metrics | Prometheus |
| Kubernetes Metrics | kube-state-metrics |
| Node Metrics | Node Exporter |
| Logging | Grafana Loki |
| Log Collection | Grafana Alloy |
| Visualization | Grafana |
| Storage | Amazon EBS / gp3 |
| EBS Integration | AWS EBS CSI Driver |
| Version Control | Git / GitHub |

---

## Infrastructure

The EKS environment was provisioned using Terraform.

### AWS components

- Amazon VPC
- Private subnets
- Amazon EKS cluster
- EKS managed node group
- IAM roles
- IRSA
- AWS EBS CSI Driver
- Amazon EBS gp3 storage
- CloudWatch control-plane logging

The EKS cluster used a managed node group with `t3.medium` instances during development.

Infrastructure configuration is located under:

```text
terraform/
├── data.tf
├── ebs-csi.tf
├── eks.tf
├── provider.tf
├── variables.tf
├── version.tf
└── vpc.tf
```

Terraform state and plan files are intentionally excluded from Git.

---

# Observability Stack

## Prometheus

Prometheus collects Kubernetes and infrastructure metrics.

The deployment uses:

- kube-prometheus-stack
- kube-state-metrics
- Prometheus Operator
- Node Exporter
- Alertmanager

Metrics validated during implementation included:

### Node CPU

```promql
100 * (
  1 - avg by(instance) (
    rate(node_cpu_seconds_total{mode="idle"}[5m])
  )
)
```

### Node Memory

```promql
100 * (
  1 - node_memory_MemAvailable_bytes
  / node_memory_MemTotal_bytes
)
```

### Pod Restarts

```promql
sum by(namespace,pod) (
  kube_pod_container_status_restarts_total
)
```

Prometheus successfully exposed Kubernetes and node metrics through active targets.

---

## Loki

Grafana Loki provides centralized Kubernetes log storage.

Loki was configured with persistent storage using Amazon EBS.

The final storage path was:

```text
Kubernetes PVC
      │
      ▼
gp3 StorageClass
      │
      ▼
AWS EBS
      │
      ▼
Loki
```

The AWS EBS CSI Driver provides Kubernetes integration with EBS volumes.

---

## Grafana Alloy

Grafana Alloy runs as a DaemonSet and collects Kubernetes pod logs from the cluster.

The logging pipeline is:

```text
Kubernetes Pods
      │
      ▼
Grafana Alloy
      │
      ▼
Loki
      │
      ▼
Grafana
```

Alloy was configured using:

```text
discovery.kubernetes
        ↓
loki.source.kubernetes
        ↓
loki.write
        ↓
Loki
```

Log ingestion was validated by querying Loki directly and retrieving Kubernetes pod logs.

---

# Grafana

Grafana provides the visualization and alerting layer.

The project contains an **EKS Observability Overview** dashboard with nine panels covering cluster and workload health.

Dashboard UID:

```text
ad2wzlx
```

The dashboard includes operational views for areas such as:

- Node CPU utilization
- Node memory utilization
- Kubernetes workload health
- Pod restart activity
- Cluster resource information
- Kubernetes observability metrics

---

## Alerting

Four operational alert rules were configured in Grafana:

1. **High Node CPU Utilization**
2. **High Node Memory Utilization**
3. **Excessive Pod Restarts**
4. **Kubernetes Node Not Ready**

Alerts were configured with Grafana contact-point routing and evaluation behavior.

---

# Dashboard as Code

The Grafana dashboard is stored in Git:

```text
grafana/
└── dashboards/
    └── eks-observability-overview.json
```

The dashboard is automatically provisioned into Grafana using a Kubernetes ConfigMap and Grafana dashboard sidecar.

The provisioning flow is:

```text
Git
 │
 ▼
Dashboard JSON
 │
 ▼
Kubernetes ConfigMap
 │
 │ grafana_dashboard: "1"
 ▼
Grafana Sidecar
 │
 ▼
Grafana
 │
 ▼
EKS Observability Overview
```

This removes the dependency on manually recreating the dashboard after deployment.

---

# Repository Structure

```text
eks-observability-platform/
│
├── terraform/
│   ├── data.tf
│   ├── ebs-csi.tf
│   ├── eks.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── version.tf
│   └── vpc.tf
│
├── helm/
│   ├── alloy/
│   │   └── values.yaml
│   │
│   ├── kube-prometheus-stack/
│   │   └── values.yaml
│   │
│   └── loki/
│       └── values.yaml
│
├── kubernetes/
│   └── grafana/
│       └── dashboard-configmap.yaml
│
├── grafana/
│   └── dashboards/
│       └── eks-observability-overview.json
│
├── docs/
│   ├── architecture/
│   │   └── architecture.md
│   │
│   └── decisions/
│       └── 001-aws-eks-architecture.md
│
├── kubernetes-gp3-storageclass.yaml
│
├── .gitignore
│
└── README.md
```

---

# Deployment Workflow

The platform was built incrementally.

## 1. Provision infrastructure

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply
```

## 2. Configure Kubernetes access

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name eks-obs-platform
```

## 3. Install Prometheus stack

```bash
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

helm repo update
```

Then deploy using the repository values:

```bash
helm upgrade --install observability \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f helm/kube-prometheus-stack/values.yaml
```

## 4. Install Loki

```bash
helm repo add grafana \
  https://grafana.github.io/helm-charts

helm repo update

helm upgrade --install loki \
  grafana/loki \
  --namespace logging \
  --create-namespace \
  -f helm/loki/values.yaml
```

## 5. Install Alloy

```bash
helm upgrade --install alloy \
  grafana/alloy \
  --namespace logging \
  -f helm/alloy/values.yaml
```

## 6. Apply Grafana dashboard provisioning

```bash
kubectl apply \
  -f kubernetes/grafana/dashboard-configmap.yaml
```

The Grafana sidecar automatically detects the ConfigMap and provisions the dashboard.

---

# Validation

The platform was validated at multiple layers.

## Kubernetes

```bash
kubectl get nodes
kubectl get pods -A
```

## Prometheus

Prometheus targets and metric queries were verified through the Prometheus API.

## Loki

Loki readiness was verified:

```bash
curl http://loki:3100/ready
```

Log queries successfully returned Kubernetes pod logs.

## Alloy

Alloy DaemonSet pods were verified as healthy and log ingestion was validated through Loki.

## Grafana

Grafana health was verified through:

```bash
curl http://localhost:3000/api/health
```

The dashboard was also verified through the Grafana API using UID:

```text
ad2wzlx
```

---

# Security Considerations

The project follows several basic security practices:

- EKS infrastructure managed through Terraform
- IAM roles used for AWS integrations
- IRSA enabled for Kubernetes AWS access
- EBS CSI access provided through an IAM role
- Terraform state excluded from Git
- Terraform plan files excluded from Git
- Terraform variable files excluded from Git
- No long-lived AWS access keys stored in the repository
- Kubernetes services kept internal where external access was unnecessary

---

# Cost Considerations

The EKS environment was created for development and portfolio purposes.

AWS resources such as:

- EKS
- EC2 worker nodes
- NAT Gateway
- EBS volumes
- CloudWatch logs

can generate charges.

After testing, the infrastructure was destroyed using:

```bash
terraform destroy
```

The Git repository remains available so the environment can be recreated when required.

---

# Key Engineering Decisions

## Why EKS?

Amazon EKS provides managed Kubernetes control-plane infrastructure while allowing practical experience with:

- Kubernetes workloads
- IAM
- networking
- storage
- observability
- AWS integrations

## Why Prometheus?

Prometheus provides Kubernetes-native metrics collection and PromQL-based querying.

## Why Loki?

Loki provides centralized log aggregation while integrating naturally with Grafana.

## Why Alloy?

Grafana Alloy provides Kubernetes-aware log discovery and forwarding to Loki.

## Why Terraform?

Terraform makes the AWS infrastructure reproducible and version-controlled.

## Why Helm?

Helm provides repeatable deployment and configuration of the observability stack.

## Why Dashboard as Code?

Storing the Grafana dashboard in Git makes the visualization layer reproducible rather than dependent on manual configuration.

---

# Project Outcomes

The completed platform demonstrates practical experience with:

- AWS EKS
- Kubernetes
- Terraform
- IAM / IRSA
- AWS EBS CSI
- Kubernetes persistent storage
- Prometheus
- PromQL
- Grafana
- Loki
- Grafana Alloy
- Kubernetes log collection
- Grafana alerting
- Helm
- Dashboard provisioning
- Git-based infrastructure management

---

# Future Improvements

Possible future enhancements include:

- GitHub Actions CI/CD for Terraform and Helm
- GitOps deployment using Argo CD
- External DNS and ingress
- TLS with cert-manager
- Remote Terraform state using S3 and DynamoDB
- S3 object storage for long-term Loki retention
- Alertmanager integrations such as Slack or email
- Centralized secrets management
- Multi-environment Terraform configuration
- SLO/SLI dashboards
- Automated observability smoke tests

---

## Author

Built as a hands-on Cloud & DevOps engineering project to demonstrate practical experience designing, provisioning, operating, and documenting a Kubernetes observability platform on AWS.
