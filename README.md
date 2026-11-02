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

---

## Secure Deployment Prerequisites

This project uses Terraform and Ansible to deploy a cloud-native application on AWS.

### Required Environment Variables

The Ansible deployment requires two application credentials:

- `POSTGRES_PASSWORD`
- `FIRST_SUPERUSER_PASSWORD`
- `FIRST_SUPERUSER_EMAIL` (optional; defaults to `admin@example.com`)

These credentials must be supplied securely to the environment running Ansible.

For the Terraform-driven deployment, supply them to the shell or CI/CD execution environment before invoking Terraform.

Do not commit passwords, AWS credentials, SSH private keys, or Terraform state files to Git.

For production environments, use a centralized secrets management solution such as AWS Secrets Manager.

### SSH Host-Key Verification

SSH host-key verification is enabled.

Before Ansible connects to a newly provisioned EC2 instance:

1. Obtain the instance's SSH host public key through a trusted, authenticated channel.
2. Independently verify the host key belongs to the intended instance.
3. Add the verified key to the SSH client's protected `known_hosts` file.
4. Run Ansible with strict host-key verification enabled.

Do not automatically trust unverified host keys.

### Terraform and Ansible Integration

Terraform invokes the Ansible deployment through a `local-exec` provisioner.

The execution environment must provide the required application credentials.

The current automated deployment workflow also requires a trusted SSH host key to be established before the first Ansible connection.

Until host-key enrollment is integrated into the provisioning workflow, a newly created instance may require a separate trust-establishment step.

### Terraform State Security

Terraform state files can contain sensitive infrastructure information.

Local state files and backups are excluded from Git through `.gitignore`.

For production deployments, use a secured remote Terraform backend with encryption and appropriate access controls.

### Security Validation

Before publication or deployment, perform:

- Gitleaks scanning of Git history and current files.
- Ansible syntax validation.
- Terraform formatting and configuration validation.
- Manual review of infrastructure configuration and documentation.
- Verification that no real credentials are committed.
