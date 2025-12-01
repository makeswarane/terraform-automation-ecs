# infra/modules/alb/main.tf
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
  tags = { Name = "${var.environment}-alb" }
}

# HTTP → HTTPS Redirect
resource "aws_lb_listener" "http" {
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

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

# Target Groups
resource "aws_lb_target_group" "wordpress" {
  name        = "${var.environment}-wp"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path     = "/wp-admin/install.php"
    matcher  = "200-399"
    interval = 30
  }
}

resource "aws_lb_target_group" "microservice" {
  name        = "${var.environment}-ms"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group" "instance" {
  name        = "${var.environment}-inst"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group" "docker" {
  name        = "${var.environment}-docker"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

# Host-based Routing Rules
resource "aws_lb_listener_rule" "wordpress" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
  condition {
    host_header {
      values = ["wordpress.${var.domain_name}"]
    }
  }
}

resource "aws_lb_listener_rule" "microservice" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.microservice.arn
  }
  condition {
    host_header {
      values = ["microservice.${var.domain_name}"]
    }
  }
}

resource "aws_lb_listener_rule" "instance" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance.arn
  }
  condition {
    host_header {
      values = ["ec2-instance.${var.domain_name}"]
    }
  }
}

resource "aws_lb_listener_rule" "docker" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 400

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docker.arn
  }
  condition {
    host_header {
      values = ["ec2-docker.${var.domain_name}"]
    }
  }
}