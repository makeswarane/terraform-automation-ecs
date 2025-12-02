variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }
variable "ecs_instance_type" {}
variable "ecs_min_size" {}
variable "ecs_max_size" {}
variable "ecs_desired_capacity" {}
variable "iam_instance_profile" {}
variable "cluster_name" {}
variable "region" {}
variable "environment" { default = "dev" }

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_launch_template" "ecs" {
  name          = "${var.cluster_name}-lt"
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = var.ecs_instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = base64encode(<<-EOT
#!/bin/bash
echo "ECS_CLUSTER=${var.cluster_name}" > /etc/ecs/ecs.config
yum update -y
yum install -y awslogs
systemctl enable awslogsd
EOT
  )
}

resource "aws_autoscaling_group" "ecs_asg" {
  name             = "${var.cluster_name}-asg"
  desired_capacity = var.ecs_desired_capacity
  max_size         = var.ecs_max_size
  min_size         = var.ecs_min_size

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.private_subnet_ids

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-ecs-instance"
    propagate_at_launch = true
  }
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}
