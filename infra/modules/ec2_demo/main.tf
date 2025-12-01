# infra/modules/ec2_demo/main.tf
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "demo" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = false

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    instance_port = var.instance_port
    docker_port   = var.docker_port
  }))

  tags = {
    Name = "${var.environment}-demo-${count.index + 1}"
  }
}

# Attach instances to ALB target groups
resource "aws_lb_target_group_attachment" "instance" {
  count            = var.instance_count
  target_group_arn = var.target_group_arns.instance
  target_id        = aws_instance.demo[count.index].id
  port             = var.instance_port
}

resource "aws_lb_target_group_attachment" "docker" {
  count            = var.instance_count
  target_group_arn = var.target_group_arns.docker
  target_id        = aws_instance.demo[count.index].id
  port             = var.docker_port
}