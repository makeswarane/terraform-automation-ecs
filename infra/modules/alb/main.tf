resource "aws_lb" "app" {
  name               = "${var.environment}-${replace(var.domain, ".", "-")}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# Listener rules for ECS target groups
resource "aws_lb_listener_rule" "wordpress" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type = "forward"
    forward {
      target_group {
        arn = var.tg_wordpress_arn
      }
    }
  }

  condition {
    host_header {
      values = ["wordpress.${var.domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "micro" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 20

  action {
    type = "forward"
    forward {
      target_group {
        arn = var.tg_micro_arn
      }
    }
  }

  condition {
    host_header {
      values = ["microservice.${var.domain}"]
    }
  }
}

# Target groups for EC2 instances (NGINX & Docker)
resource "aws_lb_target_group" "ec2_instance" {
  name        = "${var.environment}-tg-ec2-instance"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path     = "/"
    interval = 30
    matcher  = "200-399"
  }
}

resource "aws_lb_target_group" "ec2_docker" {
  name        = "${var.environment}-tg-ec2-docker"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path     = "/"
    interval = 30
    matcher  = "200-399"
  }
}

# Attach EC2 instances to target groups using count (length is known from instance_count)
resource "aws_lb_target_group_attachment" "ec2_instance_attach" {
  count            = length(var.ec2_instance_ids)
  target_group_arn = aws_lb_target_group.ec2_instance.arn
  target_id        = var.ec2_instance_ids[count.index]
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_docker_attach" {
  count            = length(var.ec2_docker_ids)
  target_group_arn = aws_lb_target_group.ec2_docker.arn
  target_id        = var.ec2_docker_ids[count.index]
  port             = 8080
}

# Listener rules for EC2
resource "aws_lb_listener_rule" "instance_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 30

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.ec2_instance.arn
      }
    }
  }

  condition {
    host_header {
      values = ["ec2-instance.${var.domain}", "instance.${var.domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "docker_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 40

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.ec2_docker.arn
      }
    }
  }

  condition {
    host_header {
      values = ["ec2-docker.${var.domain}", "docker.${var.domain}"]
    }
  }
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}
