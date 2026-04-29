# Password Pusher DevOps Final Project Presentation

## Slide 1 — Title
**Password Pusher on AWS**  
DevOps Final Project  
Povilas Kulboka

---

## Slide 2 — Project Idea
### Problem
Teams often share passwords, links, and sensitive information through chat or email.  
This is insecure because:
- messages stay visible for a long time,
- credentials can be copied multiple times,
- there is no expiration or view limit,
- there is little control or auditability.

### Idea
Deploy a self-hosted instance of **Password Pusher** that allows users to:
- share secrets securely,
- set expiration rules,
- limit the number of views,
- reduce the risk of long-term credential exposure.

---

## Slide 3 — Project Goal
### Main Goal
Build a production-style DevOps solution around Password Pusher using:
- **Docker** for containerization,
- **Terraform** for infrastructure as code,
- **AWS** for hosting,
- **GitHub Actions** for CI/CD,
- **Prometheus + Grafana** for monitoring,
- **Cloudflare** for DNS and edge protection.

### Expected Result
A secure, automated, monitored, and reproducible deployment.

---

## Slide 4 — Application Overview
### Application
The application is **Password Pusher** — a Ruby on Rails web app.

### What it does
- creates secure secret-sharing links,
- supports expiration by time or number of views,
- helps avoid sending passwords directly in plain text.

### My adaptation
- deployed my own hosted version,
- customized branding with Code Academy visuals,
- integrated it into a full DevOps workflow.

---

## Slide 5 — Chosen Infrastructure Solution
### Why AWS
I chose AWS because it provides all the services needed for a realistic cloud deployment:
- networking,
- compute,
- IAM and security,
- load balancing,
- certificate management,
- systems management.

### Main Infrastructure Components
- **VPC** with public and private subnet
- **Application Load Balancer** for HTTPS traffic
- **EC2 instance** in a private subnet
- **NAT Gateway** for outbound internet access
- **ACM certificate** for TLS
- **SSM Session Manager** instead of SSH
- **S3** for Terraform state and deployment config files
- **Cloudflare** for DNS and proxying

---

## Slide 6 — Architecture
### High-Level Flow
1. User opens `pwpush.kulboka.com`
2. Request goes through **Cloudflare**
3. Traffic reaches **AWS Application Load Balancer** over HTTPS
4. ALB forwards traffic to **Password Pusher** running on EC2
5. Password Pusher uses **PostgreSQL** as its database
6. Monitoring data is collected by **Prometheus** and visualized in **Grafana**

### Important Design Choice
The EC2 instance is in a **private subnet**, so it is not directly exposed to the internet.

---

## Slide 7 — Dockerized Application Stack
### Containers Used
The project runs as a multi-container stack with [`docker-compose.yml`](final-project/docker-compose.yml):
- **pwpush** — main application
- **postgres** — database
- **prometheus** — metrics collection
- **grafana** — dashboards
- **cadvisor** — container metrics
- **node-exporter** — host metrics

### Network Separation
- **frontend** network
- **backend** network
- **monitoring** network

This improves isolation and follows better security practices.

---

## Slide 8 — Infrastructure as Code
### Terraform
All infrastructure is defined in Terraform under [`final-project/terraform/`](final-project/terraform/).

### Managed Resources
- VPC and subnets
- route tables and gateways
- security groups
- IAM roles and instance profile
- EC2 instance
- ALB and target groups
- ACM certificate
- Cloudflare DNS records
- SSM parameters
- S3 config bucket

### Benefit
The environment is reproducible, version-controlled, and easy to rebuild.

---

## Slide 9 — Security Decisions
### Security Measures Implemented
- **No SSH access** — managed only through AWS SSM
- **Port 22 closed**
- **HTTPS only** through ALB + ACM
- **Cloudflare proxy** hides origin and adds protection
- **Private subnet** for EC2
- **Restricted security groups**
- **Secrets in SSM Parameter Store**
- **Trivy image scanning** in CI pipeline

### Why this matters
The project is not just deployed — it is deployed with security in mind.

---

## Slide 10 — CI/CD Pipeline
### GitHub Actions Workflow
The pipeline in [`.github/workflows/deploy-pwpush.yml`](final-project/.github/workflows/deploy-pwpush.yml) automates deployment.

### Pipeline Steps
1. Checkout code
2. Build Docker image
3. Run Trivy security scan
4. Push image to Docker Hub
5. Authenticate to AWS using OIDC
6. Find EC2 instance dynamically by tag
7. Deploy through SSM RunCommand
8. Run health checks

### Benefit
Deployment is automated and repeatable with minimal manual work.

---

## Slide 11 — Monitoring and Observability
### Monitoring Stack
- **Prometheus** scrapes metrics
- **Grafana** displays dashboards
- **cAdvisor** provides container metrics
- **Node Exporter** provides VM metrics

### What I monitor
- container CPU and memory usage,
- host resource usage,
- service availability,
- application health.

### Result
The project includes not only deployment, but also visibility into runtime behavior.

---

## Slide 12 — Custom Domain and Access
### Public Endpoints
- **Application**: `pwpush.kulboka.com`
- **Grafana**: `grafana.kulboka.com`

### DNS Setup
Cloudflare DNS records are created automatically with Terraform.

### Benefit
The project looks and behaves like a real hosted service, not just a local lab setup.

---

## Slide 13 — Main Challenges
### 1. User-data size limit
AWS EC2 user-data has a size limit of about 16 KB.  
My bootstrap script became too large when embedding Docker Compose and monitoring configs.

### 2. Grafana dashboard issues
Dashboards were not visible at first, and later showed no data.

### 3. DNS and branding issues
Cloudflare DNS propagation and asset caching caused confusion during testing.

### 4. Deployment reliability
Some values were hardcoded at first, which made the pipeline less flexible.

---

## Slide 14 — How I Solved Them
### User-data limit solution
I moved configuration files to an **S3 config bucket** and downloaded them in [`user-data.sh`](final-project/terraform/templates/user-data.sh).

### Grafana fixes
- fixed dashboard provisioning path,
- fixed Prometheus datasource UID mismatch,
- restarted Grafana with corrected provisioning.

### DNS and branding fixes
- verified Cloudflare records,
- waited for propagation,
- purged Cloudflare cache,
- replaced asset-pipeline logo files directly.

### Deployment improvements
- switched to **OIDC** for GitHub Actions,
- removed hardcoded EC2 instance ID,
- used dynamic instance discovery by tag.

---

## Slide 15 — Lessons Learned
### What I learned
- real DevOps work includes a lot of debugging, not only writing code,
- cloud networking and DNS issues can be subtle,
- observability is essential for troubleshooting,
- infrastructure as code makes recovery much easier,
- security decisions should be built in from the start.

---

## Slide 16 — Final Result
### Final Outcome
I built a complete DevOps project that includes:
- a real application,
- containerization,
- cloud infrastructure,
- CI/CD automation,
- monitoring,
- security hardening,
- custom domain and branding.

### Summary
This project demonstrates how to take an existing application and turn it into a production-style cloud deployment.

---

## Slide 17 — Demo Checklist
### During the presentation I can show:
- the live app at `pwpush.kulboka.com`,
- the Grafana dashboard,
- the Terraform structure,
- the GitHub Actions workflow,
- the Docker Compose stack,
- the security setup with SSM and no SSH.

---

## Slide 18 — Closing
**Thank you**

Password Pusher DevOps Final Project  
AWS + Terraform + Docker + GitHub Actions + Prometheus/Grafana
