##############################
# ECS Cluster on EC2 (EC2 launch type)
##############################

# Get latest Amazon Linux 2 ECS-optimized AMI
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.environment}-ecs-lt-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.ecs_instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.private_sg_id] # SG from network module (ECS/EC2 app SG)
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config
EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.environment}-ecs-ec2"
      Environment = var.environment
    }
  }
}

##############################
# Auto Scaling Group FOR ECS EC2
##############################

resource "aws_autoscaling_group" "ecs_asg" {
  # use name_prefix so AWS appends a unique suffix and we never clash again
  name_prefix = "${var.environment}-ecs-asg-"

  min_size         = var.ecs_min_size
  max_size         = var.ecs_max_size
  desired_capacity = var.ecs_desired_capacity

  # IMPORTANT: put ECS instances in PUBLIC subnets so they can reach Docker Hub
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.environment}-ecs-ec2"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

##############################
# ECS Cluster
##############################

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

##############################
# (Optional) Output used by root module
##############################

# keep outputs in outputs.tf if you already have them there.
# If you don't have outputs.tf, you can create it with:

# output "cluster_name" {
#   value = aws_ecs_cluster.main.name
# }
