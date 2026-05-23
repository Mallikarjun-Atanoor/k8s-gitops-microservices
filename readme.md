# Kubernetes GitOps Microservices Platform

## Overview

Production-style Kubernetes platform deployment built on a highly available kubeadm cluster using GitOps principles with ArgoCD.

The platform simulates a realistic enterprise Kubernetes environment with:

* HA Kubernetes control plane
* GitOps-driven deployments
* Stateful and stateless workloads
* Horizontal autoscaling
* Observability stack
* Namespace resource governance
* Centralized monitoring
* Private container registry integration
* Platform service separation

The repository is structured to represent a platform engineering style deployment model where infrastructure components, application workloads, and operational tooling are separated into independent domains.

---

# High-Level Architecture

## Core Platform Components

| Component      | Purpose                                                   |
| -------------- | --------------------------------------------------------- |
| kubeadm        | Kubernetes cluster bootstrap and control plane management |
| etcd           | Distributed Kubernetes datastore                          |
| Calico         | CNI networking and pod communication                      |
| ArgoCD         | GitOps deployment controller                              |
| Prometheus     | Metrics collection and monitoring                         |
| Grafana        | Visualization and dashboards                              |
| Metrics Server | Resource metrics for autoscaling                          |
| PostgreSQL     | Stateful backend database                                 |
| HPA            | Dynamic workload autoscaling                              |
| ECR            | Private container image registry                          |

---

# Cluster Topology

## Control Plane Nodes

| Node            | Responsibility                                  |
| --------------- | ----------------------------------------------- |
| control-plane-1 | API server, scheduler, controller-manager, etcd |
| control-plane-2 | HA control plane replica                        |
| control-plane-3 | HA control plane replica                        |

## Worker Nodes

| Node          | Responsibility                       |
| ------------- | ------------------------------------ |
| worker-node-1 | Application and monitoring workloads |
| worker-node-2 | Application and monitoring workloads |

---

# Repository Structure

```text
.
├── argocd/
├── monitoring/
├── platform/
├── tic-tac-toe/
└── kustomization.yaml
```

---

# Directory Breakdown

## argocd/

Contains ArgoCD Application definitions used to bootstrap GitOps-managed deployments.

### Responsibilities

* Registers monitoring stack deployment
* Registers application stack deployment
* Defines Git repository synchronization targets
* Enables automated reconciliation
* Maintains declarative deployment state

### Key Components

| File                 | Purpose                       |
| -------------------- | ----------------------------- |
| app-monitoring.yaml  | Deploys monitoring stack      |
| app-tic-tac-toe.yaml | Deploys application workloads |

---

## monitoring/

Contains observability stack configuration.

### Responsibilities

* Cluster monitoring
* Metrics collection
* Dashboard provisioning
* Alerting foundation
* Platform observability

### Stack Components

| Component             | Purpose                       |
| --------------------- | ----------------------------- |
| Prometheus            | Metrics scraping and storage  |
| Grafana               | Dashboard visualization       |
| kube-prometheus-stack | Monitoring operator stack     |
| ServiceMonitors       | Application metrics discovery |

### Monitoring Features

* Node metrics
* Kubernetes control plane monitoring
* etcd monitoring
* Scheduler monitoring
* Controller manager monitoring
* Application workload monitoring
* Pod resource utilization
* HPA metric integration

### Grafana

Includes:

* Persistent storage
* Custom dashboard provisioning
* Kubernetes platform dashboards
* Application dashboards
* NodePort exposure for external access

---

## platform/

Contains reusable platform-level infrastructure abstractions.

### Responsibilities

* Shared ingress configuration
* Storage configuration
* Cluster-wide reusable platform services

### Components

| Component | Purpose                    |
| --------- | -------------------------- |
| ingress/  | External traffic routing   |
| storage/  | Persistent storage classes |

This layer represents platform engineering ownership boundaries separate from application teams.

---

## tic-tac-toe/

Application workload domain.

Contains all runtime resources required for application deployment.

### Application Architecture

```text
Frontend
   ↓
Backend API
   ↓
PostgreSQL
```

### Components

| Component | Type                      |
| --------- | ------------------------- |
| frontend  | Stateless web application |
| backend   | Stateless API service     |
| postgres  | Stateful database         |

---

# Application Components

## frontend/

### Responsibilities

* User interface delivery
* External traffic handling
* Frontend application runtime

### Kubernetes Resources

| Resource   | Purpose                  |
| ---------- | ------------------------ |
| Deployment | Frontend pod management  |
| Service    | Internal/external access |
| HPA        | Autoscaling              |

### Scaling

Frontend scales horizontally based on CPU utilization.

---

## backend/

### Responsibilities

* API processing
* Business logic execution
* Database communication

### Kubernetes Resources

| Resource   | Purpose                             |
| ---------- | ----------------------------------- |
| Deployment | Backend pod lifecycle               |
| Service    | Internal communication              |
| ConfigMap  | Non-sensitive runtime configuration |
| HPA        | Autoscaling                         |

### Runtime Configuration

The backend consumes:

* DATABASE_URL from Kubernetes Secret
* Environment configuration from ConfigMaps
* Images from private ECR repository

---

## postgres/

### Responsibilities

* Persistent application data storage
* Stateful workload management

### Kubernetes Resources

| Resource         | Purpose                        |
| ---------------- | ------------------------------ |
| StatefulSet      | Stable database identity       |
| Headless Service | Stable networking              |
| PVC Template     | Persistent volume provisioning |

### Stateful Workload Design

The database uses:

* Persistent volumes
* Stable pod identity
* Kubernetes secrets for credentials
* Readiness and liveness probes
* Resource constraints

---

# Namespace Governance

The platform enforces namespace-level governance controls.

## ResourceQuota

Used to:

* Prevent uncontrolled resource usage
* Protect cluster stability
* Enforce workload limits

## LimitRange

Used to:

* Apply default CPU/memory requests
* Apply default CPU/memory limits
* Standardize workload resource allocation

This mirrors enterprise multi-tenant Kubernetes operational practices.

---

# GitOps Workflow

## Deployment Flow

```text
Developer Push
      ↓
Git Repository
      ↓
ArgoCD Reconciliation
      ↓
Kubernetes Cluster
      ↓
Desired State Enforcement
```

## GitOps Principles

The platform follows:

* Declarative infrastructure
* Git as source of truth
* Automated reconciliation
* Drift detection
* Continuous synchronization

Manual runtime modifications are intentionally minimized to reduce configuration drift.

---

# Security Model

## Secrets Management

Sensitive credentials are intentionally excluded from Git.

Secrets are manually created in-cluster and referenced through Kubernetes Secret objects.

### Managed Secrets

| Secret               | Purpose                           |
| -------------------- | --------------------------------- |
| db-secret            | PostgreSQL credentials            |
| ecr-secret           | Private image pull authentication |
| grafana-admin-secret | Grafana admin credentials         |

---

# Container Registry Integration

Private application images are stored in AWS ECR.

### Features

* Private image hosting
* Image pull authentication
* Kubernetes imagePullSecrets integration
* Production-style registry separation

---

# High Availability Design

## Kubernetes Control Plane HA

The platform uses:

* 3 control plane nodes
* Distributed etcd cluster
* Redundant API servers
* Scheduler redundancy
* Controller-manager redundancy

This prevents single points of failure at the orchestration layer.

---

# Observability Design

## Metrics Collection

Prometheus collects:

* Node metrics
* Pod metrics
* Control plane metrics
* Application metrics
* etcd metrics
* Scheduler metrics
* Controller-manager metrics

## Visualization

Grafana dashboards provide:

* Cluster health visibility
* Resource utilization analysis
* Workload performance monitoring
* Platform operational insights

---

# Autoscaling

Horizontal Pod Autoscalers are configured for:

* frontend workloads
* backend workloads

Scaling decisions are driven using Metrics Server CPU utilization metrics.

---

# Networking

## Internal Communication

* Kubernetes Services
* ClusterIP networking
* Calico CNI networking
* DNS-based service discovery

## External Access

Current exposure model:

* NodePort services
* Grafana external access
* ArgoCD external access

Future ingress-based routing can be layered through the platform ingress components.

---

# Operational Characteristics

## Platform Capabilities

* Declarative deployments
* Automated reconciliation
* HA orchestration layer
* Monitoring and observability
* Stateful workload support
* Namespace governance
* Resource isolation
* Horizontal scaling
* GitOps-based operations

## Production Concepts Simulated

This platform intentionally models:

* Enterprise Kubernetes operations
* Platform engineering ownership boundaries
* GitOps deployment workflows
* HA cluster management
* Observability-driven operations
* Secret separation practices
* Infrastructure/application layering

---

# Future Enhancements

Potential future platform evolution:

* Ingress controller integration
* TLS termination
* External Secrets Operator
* Vault integration
* CI/CD pipelines
* Automated ECR credential rotation
* Distributed tracing
* Service mesh
* Backup and disaster recovery
* Multi-environment GitOps promotion
* Policy enforcement with OPA/Gatekeeper
* Centralized logging stack

---

# Technology Stack

| Layer         | Technology           |
| ------------- | -------------------- |
| Orchestration | Kubernetes           |
| Bootstrap     | kubeadm              |
| Networking    | Calico               |
| GitOps        | ArgoCD               |
| Monitoring    | Prometheus           |
| Visualization | Grafana              |
| Autoscaling   | HPA + Metrics Server |
| Database      | PostgreSQL           |
| Registry      | AWS ECR              |
| Configuration | Kustomize            |

---

# Deployment Model

The repository follows a layered operational model:

```text
Platform Layer
    ↓
Observability Layer
    ↓
Application Layer
    ↓
Stateful Services Layer
```

This separation improves:

* operational ownership
* impact analysis
* deployment traceability
* service isolation
* long-term maintainability

---

# Summary

This repository represents a production-style Kubernetes GitOps platform implementing:

* HA kubeadm cluster operations
* GitOps-based deployment management
* Observability and monitoring
* Stateful and stateless workload orchestration
* Namespace governance
* Secure secret handling
* Horizontal autoscaling
* Platform/application separation

The design emphasizes operational clarity, infrastructure layering, and maintainable platform engineering practices suitable for realistic Kubernetes deployment workflows.
