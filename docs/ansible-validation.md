# Ansible Validation

## Objective

Configure the provisioned EC2 instance and deploy the application stack automatically.

---

## Playbooks Executed

### Install Docker

Responsibilities:

- Install Docker Engine
- Install Docker Compose Plugin
- Enable Docker service
- Configure Docker group permissions

---

### Deploy Application

Responsibilities:

- Clone application repository
- Generate backend environment file
- Generate frontend environment file
- Deploy application stack using Docker Compose

---

## Playbook Execution

```bash
ansible-playbook -i inventory.ini ansible/playbooks/site.yml
```

Result:

- Playbook completed successfully
- No failed tasks

---

## Validation Evidence

### Ansible Playbook Success

![Ansible Success](screenshots/ansible-playbook-success.png)

---

### Running Containers

![Docker Containers](screenshots/docker-ps-running.png)

---

### Backend Swagger UI

![Backend Swagger](screenshots/backend-swagger-ui.png)

---

### Frontend Login

![Frontend Login](screenshots/frontend-login.png)

---

### Frontend Dashboard

![Frontend Dashboard](screenshots/frontend-dashboard.png)

---

## Container Status

Application stack:

- Frontend (React + Nginx)
- Backend (FastAPI)
- PostgreSQL

All containers healthy.

---

## Application Validation

### Frontend

Accessible via:

```text
http://34.207.231.75:3000
```

---

### Backend

Accessible via:

```text
http://34.207.231.75:8000/docs
```

---

### Login Credentials

```text
Email:
challenge@devopsdojo.com

Password:
devopsdojo57
```

---

## Result

Ansible successfully configured the EC2 instance and deployed the complete application stack automatically.
