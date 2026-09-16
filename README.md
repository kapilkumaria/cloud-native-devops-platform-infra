# Cloud-Native DevOps Platform - Infrastructure Repository

Infrastructure as Code (IaC) repository for provisioning cloud infrastructure and automating application deployment using **Terraform** and **Ansible**.

---

# Overview

This repository automates the infrastructure layer of the Cloud-Native DevOps Platform.

It provisions an AWS EC2 instance using Terraform and automatically configures it with Ansible to deploy the complete application stack.

The infrastructure consists of:

- Terraform Infrastructure as Code
- AWS EC2 provisioning
- VPC networking
- Security Groups
- SSH key configuration
- Dynamic Ansible inventory generation
- Docker installation
- Docker Compose installation
- Application deployment automation
- Environment configuration templating
- Monitoring deployment placeholder

The goal of this repository is to fully automate infrastructure provisioning and application deployment using Infrastructure as Code principles.

---

# Infrastructure Architecture

![Infrastructure Diagram](docs/diagrams/Cloud-Native-DevOps-Platform%20-%20Infrastructure-Architecture.png)

Editable source:

```
docs/diagrams/infra-architecture.drawio
```

---

# Repository Structure

```
cloud-native-devops-platform-infra/
│
├── terraform/
│   ├── provider.tf
│   ├── networking.tf
│   ├── security-group.tf
│   ├── ec2.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── inventory.tf
│   └── ansible.tf
│
├── ansible/
│   ├── playbooks/
│   └── templates/
│
├── docs/
│   ├── diagrams/
│   ├── screenshots/
│   ├── terraform-validation.md
│   └── ansible-validation.md
│
└── README.md
```

---

# Technology Stack

| Technology | Purpose |
|------------|---------|
| Terraform | Infrastructure provisioning |
| AWS EC2 | Compute instance |
| AWS VPC | Networking |
| Security Groups | Firewall rules |
| Ansible | Configuration management |
| Docker | Container runtime |
| Docker Compose | Application deployment |
| GitHub | Source code |

---

# Deployment Workflow

```
Terraform Init
        │
        ▼
Terraform Apply
        │
        ▼
Provision AWS Infrastructure
        │
        ▼
Generate Dynamic Inventory
        │
        ▼
Run Ansible Playbooks
        │
        ▼
Install Docker
        │
        ▼
Clone Application Repository
        │
        ▼
Generate Environment Files
        │
        ▼
Deploy Docker Compose Stack
        │
        ▼
Application Ready
```

---

# Validation

## Terraform

Documentation:

- docs/terraform-validation.md

Screenshots:

- Terraform Apply
- EC2 Instance Running

---

## Ansible

Documentation:

- docs/ansible-validation.md

Screenshots:

- Successful Ansible Playbook
- Docker Containers Running
- Swagger UI
- Frontend Login
- Frontend Dashboard

---

# Application Endpoints

| Service | URL |
|----------|-----|
| Frontend | http://SERVER_IP:3000 |
| Backend API | http://SERVER_IP:8000 |
| Swagger | http://SERVER_IP:8000/docs |

---

# Future Enhancements

- Traefik Reverse Proxy
- HTTPS with Let's Encrypt
- Prometheus
- Grafana
- Loki
- Promtail
- CI/CD with GitHub Actions
- Kubernetes Deployment
- Helm Charts
- ArgoCD GitOps

---

# Related Repository

Application Repository

https://github.com/kapilkumaria/cloud-native-devops-platform-app

---

# License

MIT License
