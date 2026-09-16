# Cloud-Native DevOps Platform — Infrastructure

Infrastructure automation for deploying the first stage of the **Cloud-Native DevOps Platform** on AWS.

This repository uses **Terraform** to provision AWS infrastructure and **Ansible** to configure the EC2 application host. After infrastructure provisioning, Ansible automatically installs the required runtime dependencies, clones the application repository, and starts the application stack using Docker Compose.

> **Current documented scope:** AWS infrastructure provisioning and EC2 application deployment with Terraform, Ansible, Docker, and Docker Compose.

---

## 1. Architecture

The deployment flow implemented by this repository is:

```text
Local Linux Workstation
        |
        | terraform apply
        v
+-----------------------+
|      Terraform        |
+-----------------------+
        |
        |-- VPC
        |-- Public Subnet
        |-- Internet Gateway
        |-- Route Table
        |-- Security Group
        |-- Ubuntu EC2 Instance
        |
        |-- Generate Ansible inventory.ini
        |
        v
+-----------------------+
|        Ansible        |
+-----------------------+
        |
        | SSH
        v
+-----------------------+
|      AWS EC2          |
|      Ubuntu           |
+-----------------------+
        |
        |-- Install Git
        |-- Install Docker
        |-- Install Docker Compose
        |
        |-- Clone application repository
        |
        |-- Generate application environment files
        |
        |-- docker compose up -d --build
        |
        +-------------------------------+
        |               |               |
        v               v               v
   PostgreSQL        Backend         Frontend
   Container         Container       Container
```

Terraform is responsible for infrastructure provisioning and for initiating the configuration workflow.

Ansible is responsible for configuring the EC2 host and deploying the application stack.

---

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure provider |
| Terraform | Infrastructure as Code |
| Ansible | EC2 configuration and application deployment |
| Amazon VPC | Network isolation |
| Amazon EC2 | Application compute host |
| AWS Security Groups | Network access control |
| Docker | Container runtime |
| Docker Compose | Multi-container application orchestration |
| Git | Application source retrieval |
| PostgreSQL | Application database |
| FastAPI | Backend application |
| Vite/Frontend | Frontend application |

---

## 3. Repository Responsibility

This repository contains the infrastructure and configuration automation for the platform.

The application source code is maintained separately in:


`cloud-native-devops-platform-app`


During provisioning, Ansible clones the application repository onto the EC2 instance.

The current implementation uses an unauthenticated HTTPS Git clone. Therefore, the application repository must be publicly readable before running the deployment unless authenticated Git access is implemented separately.

---

## 4. Prerequisites

The workstation running the deployment requires:

- AWS account
- AWS CLI
- Terraform
- Ansible
- Git
- OpenSSH client
- Existing AWS EC2 key pair
- Corresponding private SSH key on the local workstation

Verify the required tools:

```bash
aws --version
terraform version
ansible --version
git --version
ssh -V
```

Verify AWS authentication:

```bash
aws sts get-caller-identity
```

A successful response should identify the AWS account and IAM principal being used for the deployment.

---

## 5. Clone the Infrastructure Repository

```bash
git clone https://github.com/kapilkumaria/cloud-native-devops-platform-infra.git
cd cloud-native-devops-platform-infra
```

The Terraform configuration is located under:

```text
terraform/
```

---

## 6. Terraform Environment Configuration

The repository contains:

```text
terraform/terraform.tfvars.example
```

The example file is safe to commit because it contains placeholders rather than workstation-specific values.

Create your local Terraform configuration:

```bash
cd terraform

cp terraform.tfvars.example terraform.tfvars
```

Edit:

```bash
vi terraform.tfvars
```

Configure the values for your environment:

```hcl
aws_region    = "us-east-1"
instance_type = "t3.medium"

key_name = "YOUR_EC2_KEY_PAIR_NAME"

ssh_private_key_path = "/home/YOUR_USER/.ssh/YOUR_KEY.pem"

ssh_allowed_cidr = "YOUR_PUBLIC_IP/32"
```

### Variable Explanation

#### `aws_region`

AWS region where the infrastructure will be deployed.

Example:

```hcl
aws_region = "us-east-1"
```

#### `instance_type`

EC2 instance type used for the application host.

Example:

```hcl
instance_type = "t3.medium"
```

#### `key_name`

Name of an existing AWS EC2 key pair.

Example:

```hcl
key_name = "YOUR_EC2_KEY_PAIR_NAME"
```

This is the AWS-side EC2 key pair assigned to the instance.

#### `ssh_private_key_path`

Absolute path to the corresponding private SSH key on the workstation running Terraform and Ansible.

Example:

```hcl
ssh_private_key_path = "/home/YOUR_USER/.ssh/YOUR_KEY.pem"
```

Terraform uses this value when generating the Ansible inventory so Ansible can connect to the EC2 instance.

The AWS `key_name` and local `ssh_private_key_path` must correspond to the same SSH key pair.

#### `ssh_allowed_cidr`

Public IP/CIDR permitted to SSH to the EC2 instance.

Determine the current public IPv4 address:

```bash
curl -s https://checkip.amazonaws.com
```

Then configure it as a `/32` CIDR:

```hcl
ssh_allowed_cidr = "203.0.113.10/32"
```

Replace the example address with your actual public IP.

---

## 7. Protect Local Terraform Configuration

`terraform.tfvars` contains workstation/environment-specific configuration and must not be committed.

The repository `.gitignore` excludes Terraform local files such as:

```text
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
```

Verify that the local configuration is ignored:

```bash
git check-ignore -v terraform.tfvars
```

The example configuration remains tracked:

```text
terraform.tfvars.example
```

Never commit:

- Terraform state
- Private SSH keys
- credentials
- secrets
- real environment-specific `.tfvars` files

---

## 8. Verify the EC2 Key Pair

Verify that the configured AWS key pair exists:

```bash
aws ec2 describe-key-pairs \
  --region us-east-1 \
  --key-names YOUR_EC2_KEY_PAIR_NAME
```

Verify the local private key:

```bash
ls -l /path/to/YOUR_KEY.pem
```

Recommended permissions:

```bash
chmod 400 /path/to/YOUR_KEY.pem
```

The private key must remain local and must never be committed to Git.

---

## 9. Verify Application Repository Accessibility

The current Ansible deployment clones:

```text
https://github.com/kapilkumaria/cloud-native-devops-platform-app.git
```

Because the current implementation performs an unauthenticated HTTPS clone, verify that the repository can be read without GitHub credentials:

```bash
GIT_TERMINAL_PROMPT=0 git ls-remote \
  https://github.com/kapilkumaria/cloud-native-devops-platform-app.git
```

A successful command returns Git references similar to:

```text
<commit-sha>    HEAD
<commit-sha>    refs/heads/main
```

Do not proceed with `terraform apply` if anonymous repository access fails.

A private repository without configured authentication can cause the Ansible Git task to wait for credentials and prevent the deployment from completing.

---

## 10. Initialize Terraform

From:

```text
cloud-native-devops-platform-infra/terraform
```

run:

```bash
terraform init
```

Terraform downloads the required providers and initializes the working directory.

---

## 11. Format and Validate Terraform

Check Terraform formatting:

```bash
terraform fmt -check
```

Validate the configuration:

```bash
terraform validate
```

Expected validation result:

```text
Success! The configuration is valid.
```

---

## 12. Create the Terraform Plan

Create a saved execution plan:

```bash
terraform plan -out=tfplan
```

Review the plan before applying it:

```bash
terraform show tfplan
```

Confirm that the resources Terraform intends to create match the expected architecture.

---

## 13. Deploy the Platform

Apply the reviewed Terraform plan:

```bash
terraform apply tfplan
```

The deployment contains two major stages.

### Stage 1 — Terraform Infrastructure Provisioning

Terraform creates the AWS infrastructure required by the application, including:

- VPC
- Public subnet
- Internet Gateway
- Public route table
- Route table association
- Security Group
- Ubuntu EC2 instance

The security group provides the network access required by the current platform implementation, including restricted SSH access and application access.

### Stage 2 — Ansible Configuration and Application Deployment

After the EC2 instance is available, Terraform generates:

```text
inventory.ini
```

using the Terraform `local_file` resource.

The generated inventory contains the EC2 public IP and the configured SSH information required by Ansible.

Terraform then invokes Ansible from the local workstation using a `null_resource` with a `local-exec` provisioner.

Ansible connects to the EC2 instance over SSH and executes the configuration playbooks.

The current playbook workflow:

```text
Terraform
   |
   +--> EC2 created
   |
   +--> inventory.ini generated locally
   |
   +--> local-exec starts Ansible
             |
             +--> SSH to EC2
             |
             +--> Install Docker
             |
             +--> Install Docker Compose
             |
             +--> Install Git
             |
             +--> Create application directory
             |
             +--> Clone application repository
             |
             +--> Generate application environment files
             |
             +--> docker compose up -d --build
```

Docker Compose builds and starts the application stack.

The current stack contains:

```text
PostgreSQL
Backend
Frontend
```

---

## 14. Terraform Outputs

After a successful deployment:

```bash
terraform output
```

Terraform provides:

```text
app_public_ip
frontend_url
backend_docs_url
ssh_command
```

For example:

```text
app_public_ip    = "<EC2_PUBLIC_IP>"
frontend_url     = "http://<EC2_PUBLIC_IP>:3000"
backend_docs_url = "http://<EC2_PUBLIC_IP>:8000/docs"
ssh_command      = "ssh -i <PRIVATE_KEY_PATH> ubuntu@<EC2_PUBLIC_IP>"
```

The SSH command is generated from the configured:

```hcl
ssh_private_key_path
```

so it can be used directly from the Terraform/Ansible control workstation.

---

## 15. Connect to the EC2 Instance

Retrieve the generated SSH command:

```bash
terraform output -raw ssh_command
```

Connect using the returned command.

Alternatively:

```bash
ssh -i /path/to/YOUR_KEY.pem ubuntu@<EC2_PUBLIC_IP>
```

---

## 16. Validate the Docker Deployment

On the EC2 instance:

```bash
docker images
```

The deployed stack should contain images for:

```text
cv-backend
cv-frontend
postgres
```

Check running containers:

```bash
docker ps
```

The expected containers are:

```text
cv-postgres
cv-backend
cv-frontend
```

Verify the Compose stack:

```bash
cd /opt/cloud-native-devops-platform-app

docker compose ps
```

The application containers should be running and healthy.

---

## 17. Validate the Application Locally on EC2

Test the backend Swagger documentation:

```bash
curl localhost:8000/docs
```

The response should contain the FastAPI Swagger UI HTML.

Test the OpenAPI specification:

```bash
curl -sS -o /dev/null \
  -w "OpenAPI HTTP: %{http_code}\n" \
  http://localhost:8000/api/v1/openapi.json
```

Expected:

```text
OpenAPI HTTP: 200
```

Test the frontend:

```bash
curl localhost:3000
```

The response should contain the frontend HTML document.

---

## 18. Validate the Application Externally

From the local workstation:

```bash
APP_PUBLIC_IP="$(terraform output -raw app_public_ip)"
```

Run:

```bash
curl -sS -o /dev/null -w "Frontend HTTP: %{http_code}\n" \
  "http://${APP_PUBLIC_IP}:3000/"

curl -sS -o /dev/null -w "Backend docs HTTP: %{http_code}\n" \
  "http://${APP_PUBLIC_IP}:8000/docs"

curl -sS -o /dev/null -w "OpenAPI HTTP: %{http_code}\n" \
  "http://${APP_PUBLIC_IP}:8000/api/v1/openapi.json"
```

Expected:

```text
Frontend HTTP: 200
Backend docs HTTP: 200
OpenAPI HTTP: 200
```

The frontend can also be opened at:

```text
http://<EC2_PUBLIC_IP>:3000
```

FastAPI Swagger documentation is available at:

```text
http://<EC2_PUBLIC_IP>:8000/docs
```

---

## 19. Verify Terraform Convergence

After successful provisioning and application deployment, run:

```bash
terraform plan
```

Expected:

```text
No changes. Your infrastructure matches the configuration.
```

This verifies that Terraform has converged and does not detect additional infrastructure changes after the deployment.

Inspect the managed Terraform resources:

```bash
terraform state list
```

The state should contain the expected networking, EC2, inventory, and Ansible orchestration resources.

---

## 20. Current Deployment Status

The following deployment path has been validated:

```text
Terraform configuration
        |
        v
AWS networking
        |
        v
EC2 provisioning
        |
        v
Ansible inventory generation
        |
        v
Ansible SSH configuration
        |
        v
Docker + Docker Compose installation
        |
        v
Application repository clone
        |
        v
Docker Compose build/deployment
        |
        +--> PostgreSQL healthy
        |
        +--> Backend healthy
        |
        +--> Frontend healthy
        |
        v
External HTTP validation
```

Validated HTTP endpoints:

```text
Frontend              -> HTTP 200
Backend Swagger Docs  -> HTTP 200
Backend OpenAPI       -> HTTP 200
```

Terraform post-deployment convergence has also been validated with:

```text
No changes. Your infrastructure matches the configuration.
```

---

## 21. Important Operational Notes

### Application Repository Visibility

The current Ansible implementation clones the application repository using unauthenticated HTTPS.

If the application repository is private, deployment can fail at:

```text
TASK [Clone or update application repository]
```

A typical failure is:

```text
fatal: could not read Username for 'https://github.com': terminal prompts disabled
```

Verify repository accessibility before deployment:

```bash
GIT_TERMINAL_PROMPT=0 git ls-remote \
  https://github.com/kapilkumaria/cloud-native-devops-platform-app.git
```

For private repositories, a secure authenticated Git mechanism such as a deploy key or another appropriate GitHub authentication mechanism must be implemented instead of embedding credentials in Terraform or Ansible.

### Terraform State

Terraform state is currently maintained locally by this implementation.

State files are excluded from Git and must never be committed.

### SSH Access

SSH access should be restricted to the operator's public IP using:

```hcl
ssh_allowed_cidr = "<PUBLIC_IP>/32"
```

Avoid allowing SSH from:

```text
0.0.0.0/0
```

unless explicitly required for a controlled temporary scenario.

---

## 22. Next Phases

Additional platform capabilities will be documented as they are implemented and validated.

This README intentionally documents only functionality that has been verified through the current deployment workflow.