#!/bin/bash
set -euo pipefail

# ──────────────────────────────────────────────
# EC2 User Data — Bootstrap Script
# Installs Docker, Docker Compose, and deploys
# the pwpush application stack.
# ──────────────────────────────────────────────

exec > >(tee /var/log/user-data.log) 2>&1
echo "=== User data script started at $(date) ==="

# ── System updates ──
apt-get update -y
apt-get upgrade -y

# ── Install Docker ──
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# ── Install AWS CLI (for SSM parameter retrieval) ──
apt-get install -y awscli

# ── Create application directory ──
APP_DIR="/opt/${project_name}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# ── Fetch secrets from SSM Parameter Store ──
DB_PASSWORD=$(aws ssm get-parameter --name "/${project_name}/db_password" --with-decryption --query "Parameter.Value" --output text --region "${aws_region}")
SECRET_KEY=$(aws ssm get-parameter --name "/${project_name}/secret_key_base" --with-decryption --query "Parameter.Value" --output text --region "${aws_region}")
GRAFANA_PASS=$(aws ssm get-parameter --name "/${project_name}/grafana_admin_password" --with-decryption --query "Parameter.Value" --output text --region "${aws_region}")
DOCKER_IMG=$(aws ssm get-parameter --name "/${project_name}/docker_image" --query "Parameter.Value" --output text --region "${aws_region}")
DOMAIN=$(aws ssm get-parameter --name "/${project_name}/app_domain" --query "Parameter.Value" --output text --region "${aws_region}")

# ── Create .env file ──
cat > "$APP_DIR/.env" <<EOF
DOCKER_IMAGE=$DOCKER_IMG
POSTGRES_USER=pwpush
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=pwpush_production
SECRET_KEY_BASE=$SECRET_KEY
APP_DOMAIN=$DOMAIN
GRAFANA_DOMAIN=${grafana_domain}
FORCE_SSL=true
BRAND_TITLE=Secure Password Pusher
BRAND_TAGLINE=Share passwords securely
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=$GRAFANA_PASS
EOF

chmod 600 "$APP_DIR/.env"

echo "=== User data script completed at $(date) ==="
echo "=== Application directory ready at $APP_DIR ==="
echo "=== Deploy with: cd $APP_DIR && docker compose up -d ==="
