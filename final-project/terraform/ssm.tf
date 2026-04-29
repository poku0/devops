# ──────────────────────────────────────────────
# SSM Parameter Store — Application secrets
# ──────────────────────────────────────────────
# These parameters are read by the EC2 instance
# during deployment to populate the .env file.

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project_name}/db_password"
  description = "PostgreSQL password for pwpush"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Name = "${var.project_name}-db-password"
  }
}

resource "aws_ssm_parameter" "secret_key_base" {
  name        = "/${var.project_name}/secret_key_base"
  description = "Rails SECRET_KEY_BASE for pwpush"
  type        = "SecureString"
  value       = var.secret_key_base

  tags = {
    Name = "${var.project_name}-secret-key-base"
  }
}

resource "aws_ssm_parameter" "grafana_password" {
  name        = "/${var.project_name}/grafana_admin_password"
  description = "Grafana admin password"
  type        = "SecureString"
  value       = var.grafana_admin_password

  tags = {
    Name = "${var.project_name}-grafana-password"
  }
}

resource "aws_ssm_parameter" "docker_image" {
  name        = "/${var.project_name}/docker_image"
  description = "Docker image tag for pwpush"
  type        = "String"
  value       = var.docker_image

  tags = {
    Name = "${var.project_name}-docker-image"
  }
}

resource "aws_ssm_parameter" "app_domain" {
  name        = "/${var.project_name}/app_domain"
  description = "Application domain name"
  type        = "String"
  value       = var.app_domain

  tags = {
    Name = "${var.project_name}-app-domain"
  }
}
