# Cloud-Native DevOps Platform — Infrastructure

Terraform and Ansible infrastructure repository for the **Cloud-Native DevOps Platform**. This repository supports two distinct deployment paths:

1. **EC2 + Docker Compose:** Terraform provisions AWS networking and an EC2 instance; Ansible configures the instance and deploys the application containers.
2. **Amazon EKS + Kubernetes:** Terraform defines an EKS cluster and related infrastructure, including an Amazon EBS CSI driver add-on for persistent Kubernetes storage. Application workloads are maintained in the separate Kubernetes repository.

> **Validation status (November 10, 2026):** The November EBS CSI Terraform changes passed local formatting and `terraform validate` checks, and were committed to `main`. **No Project 1 EKS cluster is currently deployed.** Do not interpret these source-level checks as proof that the add-on, Pod Identity, EBS provisioning, or PostgreSQL persistence has been validated in AWS.

---

## Overview

This repository provides infrastructure automation for two complementary learning and deployment workflows.

### Path A — EC2 and Ansible

- AWS VPC, subnet, routing, and security group configuration.
- EC2 instance provisioning and SSH connectivity.
- Terraform-generated Ansible inventory.
- Terraform-to-Ansible execution through `local-exec`.
- Docker and Docker Compose installation.
- Application repository checkout and environment-file templating.
- Application container startup and validation.

### Path B — EKS and Kubernetes

- Terraform configuration for an Amazon EKS cluster and managed node group.
- Kubernetes workloads managed separately through manifests, Kustomize, and GitOps.
- Terraform declaration of the **Amazon EBS CSI driver** add-on.
- EKS Pod Identity integration and IAM permissions for the EBS CSI controller.
- Persistent-volume support for the PostgreSQL PVC specified in the Kubernetes repository.

These paths are **alternatives**, not a single deployment sequence. An EC2 + Docker Compose deployment does not require EKS; an EKS deployment does not use this repository's EC2 Ansible deployment as its Kubernetes workload installer.

---

## Architecture

### EC2 + Ansible

![EC2 and Ansible infrastructure diagram](docs/diagrams/Cloud-Native-DevOps-Platform%20-%20Infrastructure-Architecture.png)

Editable diagram: `docs/diagrams/infra-architecture.drawio`.

```text
Engineer / CI runner
       |
       v
Terraform (EC2 configuration)
       |
       +--> VPC / networking / security groups
       +--> EC2
       +--> generated Ansible inventory
                     |
                     v
                  Ansible
                     |
                     +--> Docker / Compose
                     +--> application checkout and environment setup
                     +--> frontend + backend + PostgreSQL containers
```

> This diagram documents the **EC2 deployment path**. It is not a diagram of the EKS architecture.

### EKS + EBS-backed PostgreSQL (intended architecture)

```text
Terraform (EKS configuration)
       |
       +--> EKS cluster and managed nodes
       +--> EKS Pod Identity Agent add-on
       +--> EBS CSI controller IAM role / policy
       +--> EBS CSI driver add-on
                     |
                     v
                 Amazon EKS
                     |
                     +--> Traefik external entry point
                     |        +--> frontend ClusterIP Service
                     |        +--> backend ClusterIP Service (/api)
                     |
                     +--> PostgreSQL Deployment
                              |
                              v
                        postgres-pvc
                              |
                              v
                       gp3 StorageClass
                              |
                              v
                      Amazon EBS volume
```

The Kubernetes repository declares the PVC and StorageClass. The EBS CSI driver must be available and correctly authorized before dynamic EBS volume provisioning can succeed.

**Important limitations:** A single PostgreSQL replica backed by a `ReadWriteOnce` EBS volume is **not** a highly available database architecture. EBS volumes are Availability Zone-bound, and persistent storage is not a substitute for database backups.

---

## Repository Layout

The main infrastructure areas are:

```text
cloud-native-devops-platform-infra/
├── terraform/
│   ├── provider.tf
│   ├── networking.tf
│   ├── security-group.tf
│   ├── ec2.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── inventory.tf
│   ├── ansible.tf
│   └── eks/
│       └── ebs-csi.tf        # EBS CSI add-on and Pod Identity configuration
├── ansible/
│   ├── playbooks/
│   └── templates/
├── docs/
│   ├── diagrams/
│   ├── screenshots/
│   ├── terraform-validation.md
│   └── ansible-validation.md
└── README.md
```

The tree above highlights the key entry points rather than listing every file in the Terraform, Ansible, or EKS directories. Inspect the current source tree for the full module structure before running a deployment.

---

## Technology Stack

| Technology | Role |
| --- | --- |
| Terraform | AWS infrastructure as code |
| AWS VPC / security groups | Networking and access controls |
| Amazon EC2 | VM-based application deployment |
| Ansible | EC2 configuration and application automation |
| Docker / Docker Compose | Containerized application on EC2 |
| Amazon EKS | Managed Kubernetes control plane and worker-node platform |
| Amazon EBS / gp3 | Persistent storage for Kubernetes PostgreSQL |
| Amazon EBS CSI driver | Kubernetes-to-EBS storage integration |
| EKS Pod Identity / IAM | EBS CSI controller AWS authorization |
| GitHub | Source control and collaboration |

---

## Deployment Path A — EC2 + Docker Compose

### Workflow

```text
terraform init / validate / plan
            |
            v
      terraform apply
            |
            v
    AWS VPC / EC2 created
            |
            v
    Ansible inventory generated
            |
            v
      Ansible playbooks
            |
            +--> Install Docker and Compose
            +--> Checkout application repository
            +--> Render environment configuration
            +--> Start Docker Compose services
            |
            v
    Validate frontend / API / database
```

### Operator prerequisites

- Terraform, AWS CLI, Ansible, and SSH client configured on the execution host.
- AWS credentials with only the permissions required for the intended resources.
- An authorized EC2 key pair and accessible private SSH key; do not commit the key.
- Current administrator public IP supplied through the appropriate SSH CIDR variable.
- Required application credentials available **in the environment running Ansible**.
- A **verified SSH host key** enrolled in `known_hosts` before Ansible connects.

### Terraform checks

From the EC2 Terraform root (`terraform/`), inspect the variables and plan before applying:

```bash
cd terraform
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
```

Review the AWS account, region, ingress rules, VPC resources, EC2 instance type, Ansible trigger, and planned costs. Apply only after approving the plan and satisfying the SSH trust prerequisite.

> Terraform's `local-exec` Ansible trigger does not by itself establish SSH host-key trust. A fresh EC2 host may require a separate verified enrollment step before automated configuration can succeed.

### EC2 application endpoints

For the historical EC2 deployment, replace `SERVER_IP` with the actual EC2 address:

| Component | Endpoint |
| --- | --- |
| Frontend | `http://SERVER_IP:3000` |
| Backend API | `http://SERVER_IP:8000` |
| FastAPI Swagger UI | `http://SERVER_IP:8000/docs` |

These are **EC2/Docker Compose** endpoints. They are not the public EKS/Traefik URLs. Exposing these ports directly is appropriate only for a deliberately scoped test environment; production access should use HTTPS and restricted network controls.

### Existing evidence

- [`docs/terraform-validation.md`](docs/terraform-validation.md)
- [`docs/ansible-validation.md`](docs/ansible-validation.md)
- Screenshots under `docs/screenshots/`

These documents capture previous test evidence. They should not be construed as proof of a currently running EC2 instance.

---

## Deployment Path B — Amazon EKS

The EKS Terraform configuration is maintained under `terraform/eks/`. It is separate from the EC2 + Ansible workflow above.

### EBS CSI support added in November 2026

The `terraform/eks/ebs-csi.tf` configuration declares:

- The EKS Pod Identity Agent add-on (`eks-pod-identity-agent`).
- An IAM role with a Pod Identity trust relationship for `pods.eks.amazonaws.com`.
- An AWS-managed EBS CSI driver policy attachment.
- The EBS CSI driver add-on (`aws-ebs-csi-driver`).
- A Pod Identity association for the CSI controller ServiceAccount `ebs-csi-controller-sa`.

The configuration is designed to enable dynamic gp3-backed PV provisioning for `postgres-pvc` in the Kubernetes repository.

**Do not assume that `terraform validate` confirms the actual IAM policy is available or the add-on is compatible with the chosen EKS version.** Check provider configuration, IAM policy availability, EKS add-on support, dependencies, and the full Terraform plan before applying.

### Recommended EKS rebuild sequence

1. Identify the intended AWS account and region; verify AWS permissions and expected costs.
2. Review the current `terraform/eks/` configuration, backend/state strategy, EKS version, network settings, IAM policies, and variables.
3. Initialize and validate **from the EKS Terraform root**; do not apply the EC2 root configuration by mistake.
4. Generate and inspect a fresh EKS plan; never apply an old saved plan.
5. Apply the approved EKS plan in a controlled session.
6. Confirm EKS cluster and node-group health.
7. Confirm Pod Identity Agent and EBS CSI driver add-ons are healthy.
8. Confirm the CSI controller has the intended AWS permissions and can provision encrypted gp3 volumes.
9. Provision Kubernetes application Secrets through an approved secret-management procedure.
10. Deploy the Kustomize resources from the Kubernetes repository and validate PVC binding, workloads, and Traefik routing.
11. Test PostgreSQL data persistence across a Pod replacement and document backup/restore separately.
12. Perform cost-aware teardown and audit residual EBS volumes, especially any volumes retained by the StorageClass reclaim policy.

### Read-only verification examples

Once an EKS cluster has actually been provisioned:

```bash
aws eks list-clusters --region us-east-1

aws eks describe-addon \
  --cluster-name <EKS_CLUSTER_NAME> \
  --addon-name eks-pod-identity-agent \
  --region us-east-1

aws eks describe-addon \
  --cluster-name <EKS_CLUSTER_NAME> \
  --addon-name aws-ebs-csi-driver \
  --region us-east-1

kubectl get nodes -o wide
kubectl get pods -n kube-system
kubectl get storageclass
kubectl get pvc -n cloud-platform
```

Replace placeholders and confirm the correct Kubernetes context before issuing commands. These are **future runtime validation steps**, not already-verified November results.

### Persistent storage and teardown caveat

The Kubernetes `gp3-cloud-platform` StorageClass uses `reclaimPolicy: Retain`. Deleting a PVC or cluster may leave the underlying EBS volume behind. Retained EBS volumes can continue to incur charges and may contain application data. Identify ownership, backup requirements, and explicit authorization before deleting any retained volume.

---

## Secure Deployment Prerequisites

### Application credentials for EC2/Ansible

The Ansible path expects credentials provided through the execution environment:

- `POSTGRES_PASSWORD`
- `FIRST_SUPERUSER_PASSWORD`
- `FIRST_SUPERUSER_EMAIL` (optional; historically defaults to `admin@example.com`)

Do not commit real passwords, Terraform state, SSH keys, kubeconfig files, or cloud credentials. Avoid printing environment values or application-generated `.env` files in logs.

### Kubernetes Secrets for EKS

The EKS deployment uses separate Kubernetes Secrets for the backend and PostgreSQL. Their required names and keys are documented in the Kubernetes repository's [`secure-secret-provisioning.md`](https://github.com/kapilkumaria/cloud-native-devops-platform-kubernetes/blob/main/docs/secure-secret-provisioning.md).

The current implementation avoids embedding a password-bearing `DATABASE_URL` in the backend ConfigMap. The FastAPI backend derives its database connection configuration from environment values, including Secret-provided credentials.

Kubernetes Secrets must be provisioned **before** workloads that require them. For production, prefer an external secret manager with controlled workload identity, RBAC, encryption, and rotation.

### SSH host-key verification

SSH host-key verification is enabled for the Ansible workflow. Before the first connection:

1. Obtain the EC2 instance's host public key through a trusted, authenticated channel.
2. Verify it corresponds to the intended instance.
3. Add it to the protected SSH `known_hosts` store.
4. Only then run Ansible with strict host-key checking.

Do not automatically accept an unknown host key solely to make unattended provisioning pass.

### Terraform state

Terraform state and plan files can expose sensitive environment information. Keep them out of Git, protect local state, and use a secured remote backend with encryption, access controls, and locking for team/production workflows. Never apply a plan generated for a different state or AWS environment.

### Security checks

Before merging changes or deploying:

- Review all Terraform plans and AWS target identity.
- Run `terraform fmt -check` and `terraform validate` in the relevant root module.
- Validate Ansible syntax and the actual playbook inputs for the EC2 path.
- Scan current files **and Git history** for sensitive values with a tool such as Gitleaks.
- Confirm that no real credentials, SSH keys, state files, or generated secret manifests were committed.
- Verify container images and dependencies for security issues before public production deployment.
- Check resource ownership and residual charges during teardown.

---

## Validation Status and Known Gaps

| Component | Evidence / status |
| --- | --- |
| Historical EC2 Terraform and Ansible deployment | Documented in existing validation files/screenshots; not a claim of a live environment today |
| November EBS CSI Terraform file | Committed to `main`; local `terraform fmt` and `terraform validate` passed |
| EKS add-on provisioning | **Not runtime-verified in the November update** |
| Pod Identity / IAM authorization | **Not runtime-verified** |
| EBS gp3 provisioning and PVC `Bound` status | **Not runtime-verified** |
| PostgreSQL data persistence across Pod recreation | **Not runtime-verified** |
| Traefik frontend/backend routing after November changes | **Not runtime-verified** |
| Updated frontend Docker image | Must be rebuilt and published before the next EKS test |
| Frontend dependency security | Audit reported outstanding vulnerabilities; remediation pending |

Terraform source validation is useful, but it does not replace an AWS `plan`/`apply`, add-on status checks, PVC binding, browser tests, or database recovery tests.

---

## Future Improvements

### EC2 deployment path

- Integrate a trustworthy SSH host-key enrollment procedure into unattended provisioning.
- Add HTTPS/reverse-proxy access as appropriate for deployment beyond a temporary lab.
- Strengthen remote-state management and credential automation.

### EKS deployment path

- Complete a controlled EKS rebuild and verify Pod Identity, EBS CSI, and PostgreSQL persistence.
- Rebuild/publish an updated frontend image and validate same-origin routing through Traefik.
- Establish PostgreSQL backups, restore tests, and availability requirements.
- Remediate outstanding frontend dependency vulnerabilities before production use.
- Review infrastructure and storage cost controls, including retained EBS volumes.

**Traefik, Argo CD, Prometheus, Grafana, Loki, and Promtail are part of the broader Project 1 Kubernetes platform's source/configuration and earlier validation history; they are not EC2 infrastructure features that this Terraform/Ansible root automatically installs.** Their respective documentation belongs primarily in the Kubernetes repository.

---

## Related Repositories

- **Application:** https://github.com/kapilkumaria/cloud-native-devops-platform-app
- **Kubernetes and GitOps:** https://github.com/kapilkumaria/cloud-native-devops-platform-kubernetes

---

## License

MIT License (as stated in the original project documentation; verify the repository's license file and GitHub license metadata before treating this as a legally operative license grant).
