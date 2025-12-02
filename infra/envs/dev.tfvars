# ========================================
# ONLY EDIT THIS FILE – EVERYTHING COMES FROM HERE
# ========================================

# Global
region               = "ap-south-1"
environment          = "free"

# YOUR DOMAIN (Hostinger)
domain_name          = "piedpipers.online"

# AWS Account
account_id           = "992382671867"   # ← your AWS account id

# ACM Certificate ARN (for ALB HTTPS)
alb_certificate_arn  = "arn:aws:acm:ap-south-1:992382671867:certificate/72b46cfe-fef7-4938-9e8a-31525545196f"

# ========================
# Network
# ========================
vpc_cidr             = "10.0.0.0/20"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# ========================
# ECS Cluster (EC2 launch type)
# ========================
ecs_cluster_name     = "free-ecs"
ecs_instance_type    = "t3.micro"

ecs_min_size         = 1
ecs_max_size         = 1
ecs_desired_capacity = 1

# ========================
# RDS (WordPress DB)
# ========================
db_name              = "wordpress"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20

db_username          = "wpadmin"
# For PRODUCTION: don’t commit real password. Supply via:
#   TF_VAR_db_password environment variable or GitHub Secret.
db_password          = "SuperSecret123!"

backup_retention     = 0
skip_final_snapshot  = true

# ========================
# EC2 Demo Instances (NGINX + Docker)
# ========================
ec2_demo_count       = 2
ec2_demo_type        = "t3.micro"

# ========================
# Ports (currently NOT wired fully – optional later)
# ========================
wordpress_port       = 8081
microservice_port    = 3000
instance_port        = 8000
docker_port          = 8080
