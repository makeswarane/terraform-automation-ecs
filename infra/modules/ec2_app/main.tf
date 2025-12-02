data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  count               = var.instance_count
  ami                 = data.aws_ami.amzn2.id
  instance_type       = var.ec2_instance_type
  subnet_id           = element(var.private_subnet_ids, count.index)
  iam_instance_profile = var.iam_instance_profile
  vpc_security_group_ids = [var.private_sg_id]

  user_data = templatefile("${path.module}/userdata.sh.tpl", {
    domain = var.domain
  })

  tags = {
    Name = "${var.environment}-ec2-app-${count.index}"
  }
}

output "instance_ids" {
  value = aws_instance.app[*].id
}

output "instance_private_ips" {
  value = aws_instance.app[*].private_ip
}
