resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = merge(var.tags, { Name = "${var.project}-${var.environment}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, { Name = "${var.project}-${var.environment}-igw" })
}

resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "${var.project}-${var.environment}-public-${each.key}" })
}

resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  map_public_ip_on_launch = false
  tags = merge(var.tags, { Name = "${var.project}-${var.environment}-private-${each.key}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, { Name = "${var.project}-${var.environment}-public-rt" })
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "internet_access" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

output "vpc_id" { value = aws_vpc.this.id }
output "public_subnets" { value = [for s in aws_subnet.public : s.id] }
output "private_subnets" { value = [for s in aws_subnet.private : s.id] }
