data "aws_ami" "ecs_ami" {
  most_recent = true
  owners = ["amazon"]
  filter { name = "name"; values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"] }
}

resource "aws_launch_template" "ecs" {
  name_prefix = "${var.cluster_name}-lt-"
  image_id = data.aws_ami.ecs_ami.id
  instance_type = var.ecs_instance_type
  iam_instance_profile { name = var.iam_instance_profile }
  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", { cluster = var.cluster_name }))
  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity = var.ecs_desired
  min_size = var.ecs_min
  max_size = var.ecs_max
  vpc_zone_identifier = var.private_subnets
  launch_template {
    id = aws_launch_template.ecs.id
    version = "$$Latest"
  }
  tag {
    key = "Name"
    value = "${var.cluster_name}-ecs-instance"
    propagate_at_launch = true
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
  tags = var.tags
}

output "cluster_name" { value = aws_ecs_cluster.this.name }
