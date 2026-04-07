# 🛒 EasyShop — DevOps 3-Tier Deployment on AWS

<div align="center">

![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20EC2%20%7C%20VPC-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-Database-47A248?style=for-the-badge&logo=mongodb&logoColor=white)

**End-to-end DevOps implementation of a production-grade, scalable 3-tier e-commerce application on AWS — fully automated using Infrastructure as Code, CI/CD pipelines, containerization, and GitOps.**

</div>

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Step-by-Step Workflow](#-step-by-step-workflow)
- [Jenkins CI/CD Pipeline](#-jenkins-cicd-pipeline)
- [ArgoCD GitOps Deployment](#-argocd-gitops-deployment)
- [Kubernetes Pods](#-kubernetes-pods)
- [Application Screenshots](#-application-screenshots)
- [Key Achievements](#-key-achievements)
- [Challenges & Learnings](#-challenges--learnings)
- [Repository Structure](#-repository-structure)
- [Author](#-author)

---

## 📌 Project Overview

This project demonstrates a **complete, production-style DevOps workflow** for deploying a full-stack 3-tier e-commerce application on AWS. The focus is on designing and implementing the entire DevOps layer — from infrastructure provisioning to live deployment — using industry-standard tools and practices.

**What this project covers:**

- ✅ Cloud infrastructure provisioning from scratch using **Terraform**
- ✅ Application containerization with a multi-stage **Dockerfile**
- ✅ Fully automated CI/CD pipeline using **Jenkins** with GitHub Webhooks
- ✅ GitOps-based continuous delivery with **ArgoCD**
- ✅ Container orchestration on **AWS EKS** (Kubernetes)
- ✅ Secure configuration and secret management via K8s Secrets & ConfigMaps
- ✅ HTTPS-enabled ingress using **Nginx Ingress Controller** + **Cert-Manager**

---

## 🏗️ Architecture

```
  Developer
     │
     │  git push
     ▼
 GitHub Repo
     │
     │  Webhook trigger
     ▼
┌─────────────────────────┐
│        Jenkins          │
│    (CI — on EC2)        │
│  1. Checkout Code       │
│  2. Build Docker Image  │
│  3. Push to DockerHub   │
│  4. Update Image Tag    │
└────────────┬────────────┘
             │  Manifest updated in GitHub
             ▼
┌─────────────────────────┐
│        ArgoCD           │
│   (GitOps — on EKS)     │
│  Auto-syncs K8s manifests│
└────────────┬────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────┐
│                  AWS EKS Cluster                     │
│                                                      │
│  ┌──────────────┐       ┌──────────────┐             │
│  │   Tier 1     │       │   Tier 2     │             │
│  │  Frontend    │──────▶│   Backend    │             │
│  │  (Next.js)   │       │  (API Layer) │             │
│  └──────────────┘       └──────┬───────┘             │
│                                │                     │
│                         ┌──────▼───────┐             │
│                         │   Tier 3     │             │
│                         │   MongoDB    │             │
│                         │ (PV + PVC)   │             │
│                         └──────────────┘             │
│                                                      │
│  ┌──────────────────────────────────────────────┐    │
│  │  Nginx Ingress Controller  +  TLS (HTTPS)    │    │
│  └──────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────┘
             │
             ▼
          Browser
```

---

## 🛠️ Tech Stack

| Category | Tool / Service |
|---|---|
| ☁️ Cloud Provider | AWS — EKS, EC2, VPC, IAM |
| 🏗️ Infrastructure as Code | Terraform |
| 🐳 Containerization | Docker (multi-stage build) |
| 🔁 CI/CD | Jenkins (Declarative Pipeline) |
| 📦 Container Registry | DockerHub |
| ☸️ Orchestration | Kubernetes on AWS EKS |
| 🔄 GitOps | ArgoCD |
| 🌐 Ingress | Nginx Ingress Controller (Helm) |
| 🔒 TLS / HTTPS | Cert-Manager + Let's Encrypt |
| 🗄️ Database | MongoDB (StatefulSet with PV/PVC) |
| 💻 Application | Next.js 14 + TypeScript |
| 🔑 Version Control | GitHub |

---

## 🔄 Step-by-Step Workflow

### 1️⃣ Infrastructure Provisioning — Terraform

The entire AWS infrastructure was provisioned using Terraform with no manual setup in the AWS console.

**Resources created:**
- VPC with public and private subnets
- EKS Cluster in `eu-west-1`
- EC2 worker nodes
- Bastion Host for secure cluster access
- IAM Roles with least-privilege permissions

```bash
terraform init
terraform plan
terraform apply
```

After provisioning, kubeconfig is configured to communicate with the cluster:

```bash
aws eks --region eu-west-1 update-kubeconfig --name tws-eks-cluster
kubectl get nodes
```

---

### 2️⃣ Application Containerization — Docker

The Next.js application was containerized using a **multi-stage Dockerfile** to produce a lean, production-ready image.

- **Stage 1 (Builder):** `node:18-alpine` — installs dependencies and compiles the app
- **Stage 2 (Runner):** Minimal image containing only the built output

```bash
docker build -t anubhav1941/easyshop-app:<tag> .
docker push anubhav1941/easyshop-app:<tag>
```

---

### 3️⃣ CI/CD Pipeline — Jenkins

A **declarative Jenkins pipeline** automates the full build and delivery process, triggered automatically on every `git push` via a configured GitHub Webhook.

**Pipeline Stages:**

```
Checkout SCM  ──▶  Clone Repo  ──▶  Build Docker Image  ──▶  Login to DockerHub  ──▶  Push Docker Image
```

**Pipeline configuration highlights:**
- GitHub and DockerHub credentials stored as **Jenkins Global Credentials** — never hardcoded
- A **Jenkins Shared Library** handles reusable pipeline logic, including updating Kubernetes manifests with the new image tag after each successful build
- Build history shows iterative debugging and stabilisation from builds #2 through #7

---

### 4️⃣ Kubernetes Manifests

All Kubernetes resources are written as YAML manifests and version-controlled in GitHub. ArgoCD watches this directory and syncs any changes automatically.

| Manifest File | Resource Type |
|---|---|
| `00-cluster-issuer.yaml` | Let's Encrypt ClusterIssuer |
| `01-namespace.yaml` | Kubernetes Namespace |
| `02-pv.yaml` | MongoDB Persistent Volume |
| `03-pvc.yaml` | MongoDB Persistent Volume Claim |
| `04-configmap.yaml` | Application ConfigMap (env vars) |
| `05-secret.yaml` | Kubernetes Secrets |
| `06-mongodb-deployment.yaml` | MongoDB StatefulSet |
| `07-mongodb-service.yaml` | MongoDB ClusterIP Service |
| `08-deployment.yaml` | EasyShop App Deployment |
| `09-service.yaml` | EasyShop NodePort Service |
| `10-ingress.yaml` | Nginx Ingress with TLS |

---

### 5️⃣ GitOps Deployment — ArgoCD

ArgoCD was installed on the EKS cluster and connected to the GitHub repository. Any change to a Kubernetes manifest automatically triggers a re-sync and re-deploy — no manual `kubectl apply` required at any point.

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**ArgoCD App Configuration:**

| Setting | Value |
|---|---|
| Sync Policy | Automatic |
| Source | GitHub → `/kubernetes` path |
| Destination | `in-cluster` → `easyshop` namespace |
| Health Status | ✅ Healthy |
| Sync Status | ✅ Synced |

---

### 6️⃣ Ingress, TLS & DNS

- **Nginx Ingress Controller** deployed via Helm into a dedicated `ingress-nginx` namespace
- **Cert-Manager** deployed via Helm for automated TLS certificate provisioning and renewal
- **DNS CNAME record** configured in GoDaddy, pointing to the AWS LoadBalancer hostname
- HTTPS enforced cluster-wide via `ssl-redirect: "true"` annotation on the Ingress resource

---

## 🔧 Jenkins CI/CD Pipeline

### Stage View — Build History

> Jenkins pipeline `deployment-day` showing successful Build #7 after debugging earlier runs (#3–#6).

![Jenkins Stage View](screenshots/jenkins/jenkins-stage-view.png)

### Console Output — Build #7

> Successful Git checkout, 16-step multi-stage Docker image build, and push to DockerHub.

![Jenkins Console](screenshots/jenkins/jenkins-console.png)
![Jenkins Docker Build](screenshots/jenkins/jenkins-docker-build.png)

### Pipeline Result — SUCCESS

![Jenkins Success](screenshots/jenkins/jenkins-success.png)

---

## 🔄 ArgoCD GitOps Deployment

### Application Tile

> Application `devops-3tier-ecommerce-pipeline` showing status: **Healthy** and **Synced** to `HEAD (562b6fa)`.

![ArgoCD App Overview](screenshots/argo-cd/argocd-app-overview.png)

### Application Details Tree — Partial View

> Resource tree showing ConfigMap, Namespace, PV, PVC, Secrets, and Services — all synced 4 hours ago.

![ArgoCD Tree](screenshots/argo-cd/argocd-tree.png)

### Full Application Tree

> Complete view including Deployments, StatefulSet, HPA, DB Migration Job, ClusterIssuer, and Ingress.

![ArgoCD Full Tree](screenshots/argo-cd/argocd-full-tree.png)

**All 13 resources synced and healthy:**

| Resource Name | Kind |
|---|---|
| `easyshop-config` | ConfigMap |
| `easyshop` | Namespace |
| `mongodb-pv` | PersistentVolume |
| `mongodb-pvc` | PersistentVolumeClaim |
| `easyshop-secrets` | Secret |
| `easyshop-service` | Service |
| `mongodb-service` | Service |
| `easyshop` | Deployment |
| `mongodb` | StatefulSet |
| `easyshop-hpa` | HorizontalPodAutoscaler |
| `db-migration` | Job |
| `letsencrypt-prod` | ClusterIssuer |
| `easyshop-ingress` | Ingress |

---

## ☸️ Kubernetes Pods

> All pods confirmed running in the `easyshop` namespace on AWS EKS.

![Kubernetes Pods](screenshots/kubernetes/kubernetes-pods.png)

```bash
$ kubectl get pods -n easyshop

NAME                                  READY   STATUS      RESTARTS   AGE
db-migration-bpz2v                    0/1     Completed   0          4h11m
easyshop-5cd8b9469d-429pb             1/1     Running     0          4h11m
easyshop-5cd8b9469d-j966g             1/1     Running     0          4h11m
mongodb-0                             1/1     Running     0          4h11m
```

Two application replicas are running (managed by the Deployment), MongoDB is running as a StatefulSet, and the DB migration job completed successfully.

---

## 📸 Application Screenshots

### Homepage — Hero Banner

![Homepage Hero](screenshots/output/app-homepage-hero.png)

### Homepage — Product Categories

![Homepage Categories](screenshots/output/app-homepage-categories.png)

### Best Sellers — Product Listing

![Product Listing](screenshots/output/app-product-listing.png)

### Cart — Add to Cart Flow

![Cart](screenshots/output/app-cart.png)

### Authentication Page

![Login](screenshots/output/app-login.png)

---

## 🏆 Key Achievements

- 🚀 **Zero manual infrastructure setup** — entire AWS environment provisioned through Terraform
- ⚡ **CI/CD pipeline under 4 minutes** — from `git push` to a fresh Docker image on DockerHub
- 🔄 **True GitOps delivery** — ArgoCD auto-deploys on every manifest change; no manual `kubectl apply` at any stage
- ☸️ **Production-grade Kubernetes configuration** — HPA, PV/PVC, rolling updates, Secrets, ConfigMaps
- 🔒 **HTTPS by default** — TLS certificates auto-provisioned and renewed via Cert-Manager
- 📦 **13 Kubernetes resources** deployed and kept in continuous sync via ArgoCD
- 🟢 **Zero-downtime deployments** using Kubernetes rolling update strategy

---

## 🧗 Challenges & Learnings

### Challenges Faced

| Challenge | How It Was Resolved |
|---|---|
| GitHub authentication failures in Jenkins | Configured PAT-based credentials correctly in Jenkins Global Credentials store |
| Docker socket permission errors on EC2 | Added the `jenkins` user to the `docker` group and restarted the Jenkins service |
| Pipeline build failures (builds #3–#6) | Iteratively debugged DockerHub login, image tag format, and Shared Library path issues |
| ArgoCD UI inaccessible remotely | Used `kubectl port-forward --address=0.0.0.0` to expose ArgoCD from the Bastion host |
| TLS certificate not issuing | Traced ACME HTTP-01 challenge failures via cert-manager logs; fixed DNS propagation delay |

### Learning Outcomes

- 🌍 Practical, end-to-end experience with a **real-world CI/CD pipeline**
- ☸️ Hands-on **Kubernetes debugging** — pod logs, describe, events, exec
- 🔄 Deep understanding of **GitOps** — single source of truth, drift detection, auto-reconciliation
- 🏗️ **Terraform** — modular infrastructure code with proper state management
- ☁️ **AWS EKS** — cluster networking, node groups, IAM roles for service accounts
- 🔒 **Security** — K8s Secrets, TLS termination, IAM least-privilege

---

## 📂 Repository Structure

```
📦 easyshop-devops-3tier
├── 📁 terraform/                   # AWS infrastructure as code
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── 📁 kubernetes/                  # Kubernetes manifests (GitOps source)
│   ├── 00-cluster-issuer.yaml
│   ├── 01-namespace.yaml
│   ├── 02-pv.yaml
│   ├── 03-pvc.yaml
│   ├── 04-configmap.yaml
│   ├── 05-secret.yaml
│   ├── 06-mongodb-deployment.yaml
│   ├── 07-mongodb-service.yaml
│   ├── 08-deployment.yaml
│   ├── 09-service.yaml
│   └── 10-ingress.yaml
├── 📁 screenshots/                 # Deployment proof screenshots
├── 📄 Jenkinsfile                  # Declarative CI/CD pipeline definition
├── 📄 Dockerfile                   # Multi-stage application container build
└── 📄 README.md
```

---

## 👨‍💻 Author

**Anubhav Arora**
DevOps Engineer (Aspiring)

[![GitHub](https://img.shields.io/badge/GitHub-anubhav1941-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/anubhav1941)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/anubhavarora-devops/)

---

<div align="center">

⭐ **If this project was helpful, consider giving it a star!** ⭐

</div>
