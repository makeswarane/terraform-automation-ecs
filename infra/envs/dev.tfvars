# ========================================
# ONLY EDIT THIS FILE – EVERYTHING COMES FROM HERE
# ========================================
region               = "ap-south-1"
environment          = "free"

# YOUR DOMAIN (Hostinger)
domain_name          = "piedpipers.online"           # ← CHANGE THIS

# ACM Certificate ARN (create in ap-south-1 first)
acm_certificate_arn  = "arn:aws:acm:ap-south-1:992382671867:certificate/72b46cfe-fef7-4938-9e8a-31525545196f"  # ← PASTE LATER

# Network
vpc_cidr             = "10.0.0.0/20"
public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets      = ["10.0.11.0/24", "10.0.12.0/24"]

# ECS (smallest)
ecs_cluster_name     = "free-ecs"
ecs_instance_type    = "t3.micro"
ecs_min_size         = 1
ecs_max_size         = 1
ecs_desired_capacity = 1

# RDS (smallest + no cost)
db_name              = "wordpress"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
db_username          = "wpadmin"
db_password          = "SuperSecret123!"   # will be overridden by Secrets Manager
backup_retention     = 0
skip_final_snapshot  = true

# EC2 Demo
ec2_demo_count       = 2
ec2_demo_type        = "t3.micro"

# Ports
wordpress_port       = 8081
microservice_port    = 3000
instance_port        = 8000
docker_port          = 8080