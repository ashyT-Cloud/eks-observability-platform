# ADR-001: AWS EKS Architecture

## Status

Accepted

## Context

The project requires a production-style Kubernetes observability platform while remaining suitable for a portfolio and learning environment.

The platform must support:

- Kubernetes workloads
- Metrics collection
- Log aggregation
- Dashboards
- Alerting
- Infrastructure as Code
- Reproducible deployment

## Decision

We will deploy an Amazon EKS cluster inside a dedicated VPC using Terraform.

The initial architecture will use:

- One AWS region
- Two Availability Zones
- Public and private subnets
- EKS worker nodes in private subnets
- Managed EKS node group
- Kubernetes-based observability components
- Helm for third-party observability components

## Observability Components

### Metrics

- Prometheus
- kube-state-metrics
- Node Exporter
- Metrics Server

### Visualization

- Grafana

### Logs

- Loki
- Promtail

### Alerting

- Alertmanager
- Prometheus alert rules

## Security

Worker nodes will not be directly exposed to the public internet.

AWS access will use the dedicated `project6-terraform` CLI profile rather than the obsolete SSO profiles on the workstation.

Secrets and credentials will not be committed to Git.

## Cost Considerations

The cluster will initially use a small managed node group appropriate for a learning/portfolio environment.

AWS resources will be monitored during development and destroyed after project completion.

NAT Gateway usage and other continuously billed resources will be evaluated carefully before deployment.

## Consequences

### Positive

- Production-oriented architecture
- Multi-AZ foundation
- Private worker nodes
- Reproducible infrastructure
- Clear separation between infrastructure and observability workloads

### Negative

- More AWS resources than a single-node development cluster
- NAT/networking may introduce additional cost
- EKS and supporting resources incur ongoing charges while running

## Alternatives Considered

### Single EC2 Kubernetes Cluster

Rejected because it would not demonstrate managed Kubernetes or EKS architecture.

### Public EKS Worker Nodes

Rejected because private worker nodes provide a stronger production security model.

### Manual AWS Console Deployment

Rejected because Terraform provides reproducibility and infrastructure version control.
