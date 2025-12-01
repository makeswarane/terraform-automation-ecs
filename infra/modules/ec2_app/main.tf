resource "aws_security_group" "ec2_app" {
  count = var.create ? 1 : 0
  name = "${var.project}-${var.environment}-ec2-app-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
  tags = var.tags
}

resource "aws_instance" "app" {
  count = var.create ? var.count : 0
  ami = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id = element(var.private_subnets, count.index % length(var.private_subnets))
  vpc_security_group_ids = [aws_security_group.ec2_app[0].id]
  user_data = templatefile("${path.module}/user_data.sh.tpl", { port = var.app_port })
  tags = merge(var.tags, { Name = "${var.project}-${var.environment}-app-${count.index}" })
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  filter { name = "name"; values = ["amzn2-ami-hvm-*-x86_64-gp2"] }
}

output "instance_ids" { value = aws_instance.app[*].id }
