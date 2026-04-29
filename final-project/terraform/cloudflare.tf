# ──────────────────────────────────────────────
# Cloudflare DNS — Automated via Terraform
# ──────────────────────────────────────────────

# ACM certificate DNS validation records
resource "cloudflare_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  content = each.value.record
  type    = each.value.type
  ttl     = 60
  proxied = false # DNS-only for ACM validation

  comment = "ACM certificate validation for ${var.app_domain}"
}

# ──────────────────────────────────────────────
# Application CNAME — points to ALB
# ──────────────────────────────────────────────

resource "cloudflare_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = var.app_domain
  content = aws_lb.main.dns_name
  type    = "CNAME"
  ttl     = 1 # Auto TTL when proxied
  proxied = true # Orange cloud — Cloudflare proxy enabled

  comment = "Password Pusher application - proxied via Cloudflare"
}

# ──────────────────────────────────────────────
# Grafana CNAME — points to same ALB (host-based routing)
# ──────────────────────────────────────────────

resource "cloudflare_record" "grafana" {
  zone_id = var.cloudflare_zone_id
  name    = var.grafana_domain
  content = aws_lb.main.dns_name
  type    = "CNAME"
  ttl     = 1 # Auto TTL when proxied
  proxied = true # Orange cloud — Cloudflare proxy enabled

  comment = "Grafana monitoring dashboard - proxied via Cloudflare"
}
