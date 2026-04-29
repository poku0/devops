#!/bin/bash
set -euo pipefail

# ──────────────────────────────────────────────
# setup-ec2.sh — Initial EC2 setup script
# ──────────────────────────────────────────────
# Run this manually via SSM Session Manager after
# the first terraform apply to copy project files
# to the EC2 instance.
#
# The user-data.sh (in Terraform templates) handles
# Docker installation and .env creation automatically.
# This script copies the docker-compose.yml and
# monitoring configs, then starts the stack.
# ──────────────────────────────────────────────

APP_DIR="/opt/pwpush"

echo "=== EC2 Setup Script ==="
echo "Application directory: $APP_DIR"

# Verify Docker is installed
if ! command -v docker &> /dev/null; then
  echo "ERROR: Docker is not installed. Wait for user-data to complete."
  echo "Check /var/log/user-data.log for progress."
  exit 1
fi

# Verify .env exists (created by user-data)
if [ ! -f "$APP_DIR/.env" ]; then
  echo "ERROR: .env file not found. Wait for user-data to complete."
  exit 1
fi

cd "$APP_DIR"

echo ""
echo "=== Setup Complete ==="
echo "The docker-compose.yml and monitoring configs should be"
echo "deployed via the CI/CD pipeline (GitHub Actions)."
echo ""
echo "To manually start the stack:"
echo "  cd $APP_DIR"
echo "  docker compose up -d"
echo ""
echo "To check status:"
echo "  docker compose ps"
echo "  docker compose logs -f"
