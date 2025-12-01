resource "aws_lb" "alb" {
  name = "${var.domain}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = []
  subnets = var.public_subnets
  tags = var.tags
}

resource "aws_lb_target_group" "wordpress" {
  name = "${var.domain}-wp-tg"
  port = var.wordpress_port
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = var.vpc_id
  health_check { path = "/", protocol = "HTTP" }
}

resource "aws_lb_target_group" "microservice" {
  name = "${var.domain}-ms-tg"
  port = var.microservice_port
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = var.vpc_id
  health_check { path = "/", protocol = "HTTP" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.acm_certificate_arn != "" ? var.acm_certificate_arn : ""
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No host rule matched"
      status_code = "404"
    }
  }
}

output "alb_dns_name" { value = aws_lb.alb.dns_name }
