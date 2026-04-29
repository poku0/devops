#!/bin/bash
set -euo pipefail

# ──────────────────────────────────────────────
# EC2 User Data — Bootstrap Script
# Installs Docker, Docker Compose, downloads
# config files from S3, and starts the pwpush stack.
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

# ── Install AWS CLI v2 (for S3 downloads and SSM parameter retrieval) ──
apt-get install -y unzip
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/awscliv2.zip /tmp/aws

# ── Create application directory structure ──
APP_DIR="/opt/${project_name}"
mkdir -p "$APP_DIR"
mkdir -p "$APP_DIR/monitoring/prometheus"
mkdir -p "$APP_DIR/monitoring/grafana/provisioning/datasources"
mkdir -p "$APP_DIR/monitoring/grafana/provisioning/dashboards"
cd "$APP_DIR"

# ── Download config files from S3 ──
echo "=== Downloading config files from S3 bucket: ${config_bucket} ==="
aws s3 cp "s3://${config_bucket}/docker-compose.yml" "$APP_DIR/docker-compose.yml" --region "${aws_region}"
aws s3 cp "s3://${config_bucket}/monitoring/prometheus/prometheus.yml" "$APP_DIR/monitoring/prometheus/prometheus.yml" --region "${aws_region}"
aws s3 cp "s3://${config_bucket}/monitoring/grafana/provisioning/datasources/prometheus.yml" "$APP_DIR/monitoring/grafana/provisioning/datasources/prometheus.yml" --region "${aws_region}"
aws s3 cp "s3://${config_bucket}/monitoring/grafana/provisioning/dashboards/dashboard.yml" "$APP_DIR/monitoring/grafana/provisioning/dashboards/dashboard.yml" --region "${aws_region}"
aws s3 cp "s3://${config_bucket}/monitoring/grafana/provisioning/dashboards/docker-monitoring.json" "$APP_DIR/monitoring/grafana/provisioning/dashboards/docker-monitoring.json" --region "${aws_region}"
echo "=== Config files downloaded successfully ==="

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

# ── Start the application stack ──
echo "=== Starting Docker Compose stack ==="
cd "$APP_DIR"
docker compose up -d

echo "=== User data script completed at $(date) ==="
echo "=== Application stack starting at $APP_DIR ==="
echo "=== Check status with: docker compose -f $APP_DIR/docker-compose.yml ps ==="
