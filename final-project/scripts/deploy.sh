#!/bin/bash
set -euo pipefail

# ──────────────────────────────────────────────
# deploy.sh — Deployment script for pwpush
# ──────────────────────────────────────────────
# This script is executed on the EC2 instance via
# AWS SSM RunCommand from the CI/CD pipeline.
#
# Usage: ./deploy.sh [docker_image_tag]
# ──────────────────────────────────────────────

APP_DIR="/opt/pwpush"
DOCKER_IMAGE="${1:-}"
LOG_FILE="/var/log/pwpush-deploy.log"

echo "=== Deployment started at $(date) ===" | tee -a "$LOG_FILE"

cd "$APP_DIR"

# Update the Docker image tag in .env if provided
if [ -n "$DOCKER_IMAGE" ]; then
  echo "Updating DOCKER_IMAGE to: $DOCKER_IMAGE" | tee -a "$LOG_FILE"
  sed -i "s|^DOCKER_IMAGE=.*|DOCKER_IMAGE=$DOCKER_IMAGE|" .env
fi

# Pull the latest images
echo "Pulling latest images..." | tee -a "$LOG_FILE"
docker compose pull 2>&1 | tee -a "$LOG_FILE"

# Restart services with zero-downtime approach
echo "Restarting services..." | tee -a "$LOG_FILE"
docker compose up -d --remove-orphans 2>&1 | tee -a "$LOG_FILE"

# Wait for the application to be healthy
echo "Waiting for application health check..." | tee -a "$LOG_FILE"
MAX_RETRIES=30
RETRY_INTERVAL=5
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if curl -sf http://localhost:5100/ > /dev/null 2>&1; then
    echo "Application is healthy!" | tee -a "$LOG_FILE"
    break
  fi
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "Health check attempt $RETRY_COUNT/$MAX_RETRIES — waiting ${RETRY_INTERVAL}s..." | tee -a "$LOG_FILE"
  sleep $RETRY_INTERVAL
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
  echo "ERROR: Application failed to become healthy after $((MAX_RETRIES * RETRY_INTERVAL))s" | tee -a "$LOG_FILE"
  echo "Container status:" | tee -a "$LOG_FILE"
  docker compose ps 2>&1 | tee -a "$LOG_FILE"
  echo "Application logs:" | tee -a "$LOG_FILE"
  docker compose logs --tail=50 pwpush 2>&1 | tee -a "$LOG_FILE"
  exit 1
fi

# Clean up old images
echo "Cleaning up unused Docker images..." | tee -a "$LOG_FILE"
docker image prune -f 2>&1 | tee -a "$LOG_FILE"

echo "=== Deployment completed successfully at $(date) ===" | tee -a "$LOG_FILE"
