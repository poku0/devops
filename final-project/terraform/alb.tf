# ──────────────────────────────────────────────
# Application Load Balancer
# ──────────────────────────────────────────────

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ──────────────────────────────────────────────
# Target Group — forwards to pwpush on port 5100
# ──────────────────────────────────────────────

resource "aws_lb_target_group" "pwpush" {
  name     = "${var.project_name}-tg"
  port     = 5100
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200,301,302"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Register EC2 instance with target group
resource "aws_lb_target_group_attachment" "pwpush" {
  target_group_arn = aws_lb_target_group.pwpush.arn
  target_id        = aws_instance.app.id
  port             = 5100
}

# ──────────────────────────────────────────────
# Target Group — forwards to Grafana on port 3000
# ──────────────────────────────────────────────

resource "aws_lb_target_group" "grafana" {
  name     = "${var.project_name}-grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-grafana-tg"
  }
}

# Register EC2 instance with Grafana target group
resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana.arn
  target_id        = aws_instance.app.id
  port             = 3000
}

# ──────────────────────────────────────────────
# HTTPS Listener — port 443 with ACM certificate
# Default action forwards to pwpush
# ──────────────────────────────────────────────

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pwpush.arn
  }
}

# ──────────────────────────────────────────────
# Listener Rule — host-based routing for Grafana
# ──────────────────────────────────────────────

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  condition {
    host_header {
      values = [var.grafana_domain]
    }
  }
}

# ──────────────────────────────────────────────
# HTTP Listener — redirect to HTTPS
# ──────────────────────────────────────────────

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
