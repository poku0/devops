# ──────────────────────────────────────────────
# Outputs
# ──────────────────────────────────────────────

output "alb_dns_name" {
  description = "ALB DNS name — use for Cloudflare CNAME"
  value       = aws_lb.main.dns_name
}

output "ec2_instance_id" {
  description = "EC2 instance ID — use for SSM RunCommand in CI/CD"
  value       = aws_instance.app.id
}

output "ec2_private_ip" {
  description = "EC2 private IP address"
  value       = aws_instance.app.private_ip
}

output "app_url" {
  description = "Application URL"
  value       = "https://${var.app_domain}"
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "https://${var.grafana_domain}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP — the origin IP seen by external services"
  value       = aws_eip.nat.public_ip
}

output "ssm_connect_command" {
  description = "Command to connect to EC2 via SSM Session Manager"
  value       = "aws ssm start-session --target ${aws_instance.app.id} --region ${var.aws_region}"
}
