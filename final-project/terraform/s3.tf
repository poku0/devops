# ──────────────────────────────────────────────
# S3 Bucket — deployment config files
# Stores docker-compose.yml and monitoring configs
# that are too large to embed in EC2 user-data (16KB limit).
# ──────────────────────────────────────────────

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "config" {
  bucket = "${var.project_name}-config-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-config"
  }
}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket = aws_s3_bucket.config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ──────────────────────────────────────────────
# Upload config files to S3
# ──────────────────────────────────────────────

resource "aws_s3_object" "docker_compose" {
  bucket = aws_s3_bucket.config.id
  key    = "docker-compose.yml"
  source = "${path.module}/../docker-compose.yml"
  etag   = filemd5("${path.module}/../docker-compose.yml")
}

resource "aws_s3_object" "prometheus_config" {
  bucket = aws_s3_bucket.config.id
  key    = "monitoring/prometheus/prometheus.yml"
  source = "${path.module}/../monitoring/prometheus/prometheus.yml"
  etag   = filemd5("${path.module}/../monitoring/prometheus/prometheus.yml")
}

resource "aws_s3_object" "grafana_datasources" {
  bucket = aws_s3_bucket.config.id
  key    = "monitoring/grafana/provisioning/datasources/prometheus.yml"
  source = "${path.module}/../monitoring/grafana/provisioning/datasources/prometheus.yml"
  etag   = filemd5("${path.module}/../monitoring/grafana/provisioning/datasources/prometheus.yml")
}

resource "aws_s3_object" "grafana_dashboards" {
  bucket = aws_s3_bucket.config.id
  key    = "monitoring/grafana/provisioning/dashboards/dashboard.yml"
  source = "${path.module}/../monitoring/grafana/provisioning/dashboards/dashboard.yml"
  etag   = filemd5("${path.module}/../monitoring/grafana/provisioning/dashboards/dashboard.yml")
}

resource "aws_s3_object" "grafana_dashboard_json" {
  bucket = aws_s3_bucket.config.id
  key    = "monitoring/grafana/provisioning/dashboards/docker-monitoring.json"
  source = "${path.module}/../monitoring/grafana/provisioning/dashboards/docker-monitoring.json"
  etag   = filemd5("${path.module}/../monitoring/grafana/provisioning/dashboards/docker-monitoring.json")
}

# ──────────────────────────────────────────────
# S3 VPC Gateway Endpoint — free, allows EC2 in
# private subnet to reach S3 without NAT Gateway
# ──────────────────────────────────────────────

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.project_name}-s3-endpoint"
  }
}
