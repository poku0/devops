# Password Pusher — DevOps Final Project

A self-hosted, customized deployment of [Password Pusher (pwpush)](https://github.com/poku0/PasswordPusher) (forked from [upstream](https://github.com/pglombardo/PasswordPusher)) on AWS, built from source with custom branding. Demonstrates DevOps best practices including Infrastructure as Code, CI/CD automation, security hardening, and full observability.

## Architecture

```
Internet → Cloudflare (DNS + Proxy + WAF)
         → AWS ALB (HTTPS 443, ACM cert)
         → EC2 Private Subnet (SSM managed, no SSH)
           ├── pwpush (Rails app, port 5100)
           ├── PostgreSQL 16 (isolated backend network)
           ├── Prometheus (metrics collection)
           ├── Grafana (dashboards)
           ├── cAdvisor (container metrics)
           └── Node Exporter (host metrics)
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **No SSH (port 22 closed)** | AWS SSM Session Manager for access — eliminates SSH key management |
| **Private subnet for EC2** | No direct internet exposure; outbound via NAT Gateway |
| **ALB + ACM** | HTTPS termination with AWS-managed SSL certificate |
| **Cloudflare proxy** | DDoS protection, WAF, origin IP hiding, edge TLS |
| **Isolated DB network** | PostgreSQL on Docker `internal` network — unreachable from internet |
| **SSM Parameter Store** | Secrets stored encrypted, fetched at deploy time — never in code |
| **Cloudflare via Terraform** | DNS records automated — no manual dashboard steps |

## Project Structure

```
final-project/
├── README.md                          # This file
├── .env.example                       # Environment variable template
├── .gitignore                         # Git ignore rules
├── docker-compose.yml                 # Multi-container orchestration
├── Dockerfile                         # Multi-stage build from fork
├── branding/                          # Custom logo, favicon
├── config/
│   └── custom_theme.css               # UI customization
├── terraform/
│   ├── provider.tf                    # AWS + Cloudflare providers
│   ├── variables.tf                   # Input variables
│   ├── outputs.tf                     # Outputs (ALB DNS, EC2 ID, etc.)
│   ├── vpc.tf                         # VPC, subnets, IGW, NAT
│   ├── security-groups.tf             # ALB SG, EC2 SG, VPC endpoint SG
│   ├── iam.tf                         # SSM role, instance profile
│   ├── ec2.tf                         # EC2 instance + VPC endpoints
│   ├── alb.tf                         # ALB, target group, listeners
│   ├── acm.tf                         # SSL certificate
│   ├── cloudflare.tf                  # DNS records (automated)
│   ├── ssm.tf                         # Parameter Store secrets
│   ├── templates/user-data.sh         # EC2 bootstrap script
│   └── terraform.tfvars.example       # Example variable values
├── monitoring/
│   ├── prometheus/prometheus.yml      # Scrape configuration
│   └── grafana/provisioning/
│       ├── datasources/prometheus.yml # Auto-configure Prometheus
│       └── dashboards/
│           ├── dashboard.yml          # Provisioning config
│           └── docker-monitoring.json # Pre-built dashboard
├── scripts/
│   ├── deploy.sh                      # Deployment script (SSM)
│   ├── health-check.sh                # Post-deploy verification
│   └── setup-ec2.sh                   # Initial EC2 setup
├── tests/
│   ├── test_health.py                 # pytest health checks
│   └── requirements.txt              # Python test dependencies
└── .github/workflows/
    └── deploy-pwpush.yml              # CI/CD pipeline
```

## Prerequisites

- **AWS Account** with OIDC configured for GitHub Actions
- **Cloudflare Account** with `kulboka.com` zone
- **Docker Hub Account** for image registry
- **GitHub Repository** with the following secrets configured:

| Secret | Description |
|--------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub access token |
| `AWS_ROLE_ARN` | IAM role ARN for GitHub OIDC |
| `EC2_INSTANCE_ID` | EC2 instance ID (from Terraform output) |
| `APP_DOMAIN` | Application domain (e.g., `pwpush.kulboka.com`) |
| `DB_PASSWORD` | PostgreSQL password |
| `PWPUSH_SECRET_KEY_BASE` | Rails secret key |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token (Zone:DNS:Edit) |
| `CLOUDFLARE_ZONE_ID` | Cloudflare zone ID for kulboka.com |

## Docker Build Strategy

The [`Dockerfile`](Dockerfile) uses a **multi-stage build from the forked source**:

1. **Stage 1 (build-env):** Clones `poku0/PasswordPusher` fork, copies custom branding/CSS into the source tree, installs Ruby + Node dependencies, and precompiles Rails assets
2. **Stage 2 (runtime):** Minimal Alpine image with only runtime dependencies — copies compiled app from stage 1

```
┌─────────────────────────────────────────────────┐
│  Build Stage (ruby:4.0.3-alpine)                │
│  git clone poku0/PasswordPusher                 │
│  COPY branding/ → app/assets/images/            │
│  COPY config/custom_theme.css → stylesheets/    │
│  bundle install + yarn install                  │
│  rails assets:precompile                        │
├─────────────────────────────────────────────────┤
│  Runtime Stage (ruby:4.0.2-alpine)              │
│  COPY --from=build-env (compiled app)           │
│  HEALTHCHECK + non-root user                    │
│  ENTRYPOINT → foreman (web + worker)            │
└─────────────────────────────────────────────────┘
```

Build args allow overriding the fork repo/branch:

```bash
docker build \
  --build-arg FORK_REPO=https://github.com/poku0/PasswordPusher.git \
  --build-arg FORK_BRANCH=master \
  -t pwpush-custom .
```

## Quick Start

### 1. Fork Password Pusher

```bash
# Fork https://github.com/pglombardo/PasswordPusher to poku0/PasswordPusher
# Add your branding assets to this repo:
cp your-logo.png final-project/branding/logo.png
cp your-favicon.ico final-project/branding/favicon.ico
```

### 2. Configure Terraform Variables

```bash
cd final-project/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Deploy Infrastructure

```bash
cd final-project/terraform
terraform init
terraform plan
terraform apply
```

After apply, note the outputs:
- `ec2_instance_id` → Add as `EC2_INSTANCE_ID` GitHub secret
- `alb_dns_name` → Cloudflare CNAME is created automatically
- `ssm_connect_command` → Use to connect to EC2

### 4. Connect to EC2 via SSM

```bash
# Install AWS CLI Session Manager plugin first
aws ssm start-session --target <instance-id> --region eu-central-1
```

### 5. Verify Deployment

```bash
# The CI/CD pipeline deploys automatically on push to main
# Or run health checks manually:
APP_URL=https://pwpush.kulboka.com pytest tests/test_health.py -v
```

## CI/CD Pipeline

The pipeline runs automatically on push to `main` (with path filter on `final-project/**`):

```
Lint → Build → Trivy Scan → Push to Docker Hub → Deploy via SSM → Health Check
```

| Stage | Tool | Purpose |
|-------|------|---------|
| Lint | Hadolint + yamllint | Dockerfile and YAML validation |
| Build | Docker Buildx | Build custom pwpush image |
| Scan | Trivy | Vulnerability scan — fails on HIGH/CRITICAL |
| Push | Docker Hub | Push with `:latest` and `:sha` tags |
| Deploy | AWS SSM RunCommand | Pull and restart on EC2 — no SSH needed |
| Test | pytest + curl | Verify application is live and healthy |

## Monitoring

Grafana is publicly accessible at **https://grafana.kulboka.com** via ALB host-based routing.

- Default credentials: `admin` / (set via SSM Parameter Store `grafana_admin_password`)
- Cloudflare proxy provides DDoS protection and caching

**Pre-configured dashboards:**
- Container CPU, memory, network I/O
- Host CPU, memory, disk usage
- Running container count

## Security Measures

- ✅ **No SSH** — Port 22 closed; SSM Session Manager only
- ✅ **HTTPS only** — ALB with ACM cert + Cloudflare proxy
- ✅ **Private subnet** — EC2 not directly accessible from internet
- ✅ **Isolated DB** — PostgreSQL on Docker internal network
- ✅ **IMDSv2 required** — Instance metadata hardened
- ✅ **Encrypted EBS** — Root volume encrypted at rest
- ✅ **Secret management** — SSM Parameter Store (SecureString)
- ✅ **Image scanning** — Trivy in CI, fails on HIGH/CRITICAL
- ✅ **Least privilege SGs** — EC2 accepts traffic from ALB only
- ✅ **Cloudflare WAF** — DDoS protection + origin IP hiding
- ✅ **TLS 1.3** — Modern SSL policy on ALB

## Cost Estimate (Monthly)

| Resource | Estimated Cost |
|----------|---------------|
| EC2 t3.small | ~$15 |
| NAT Gateway | ~$32 |
| ALB | ~$16 |
| EBS 30GB gp3 | ~$2.40 |
| VPC Endpoints (3x) | ~$22 |
| Data transfer | ~$5 |
| **Total** | **~$92/mo** |

> **Cost optimization tip:** For development/demo, you can stop the EC2 instance when not in use. The NAT Gateway and VPC endpoints continue to incur charges while the VPC exists.

## Grading Rubric Coverage

| Criteria | Implementation |
|----------|---------------|
| Develop/Adapt App | ✅ Forked pwpush with custom branding |
| Dockerize | ✅ Custom Dockerfile + multi-container compose |
| IaC (Terraform) | ✅ Full AWS infra + Cloudflare DNS |
| CI/CD Pipeline | ✅ GitHub Actions: lint → build → scan → push → deploy → test |
| Security Scanning | ✅ Trivy in pipeline, fails on HIGH/CRITICAL |
| Secret Management | ✅ GitHub Secrets → SSM Parameter Store |
| Cloud Security Groups | ✅ ALB: 443 only; EC2: from ALB only; no SSH |
| Private Docker Network | ✅ PostgreSQL on internal network |
| Monitoring & Logging | ✅ Prometheus + Grafana + cAdvisor + Node Exporter |
| Automated Testing | ✅ pytest health checks + curl verification |
| Documentation | ✅ This README + architecture diagrams |
