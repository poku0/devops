# ──────────────────────────────────────────────
# ACM Certificate — SSL for ALB
# ──────────────────────────────────────────────

resource "aws_acm_certificate" "main" {
  domain_name               = var.app_domain
  subject_alternative_names = [var.grafana_domain]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-cert"
  }
}

# ──────────────────────────────────────────────
# ACM Validation — waits for DNS validation to complete
# ──────────────────────────────────────────────

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in cloudflare_record.acm_validation : record.hostname]
}
