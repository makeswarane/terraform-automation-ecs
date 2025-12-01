module "network" {
  source          = "./modules/network"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  environment     = var.environment

  # pass the AWS region expected by the network module
  region          = var.region
}


module "alb" {
  source            = "./modules/alb"
  public_subnet_ids = module.network.public_subnet_ids
  certificate_arn   = var.acm_certificate_arn

  # PASS the ALB security group id that the alb module expects
  alb_sg_id         = module.network.alb_sg_id

  environment       = var.environment
}


module "ecs_cluster" {
  source            = "./modules/ecs_cluster"
  cluster_name      = var.ecs_cluster_name
  instance_type     = var.ecs_instance_type
  min_size          = var.ecs_min_size
  max_size          = var.ecs_max_size
  desired_capacity  = var.ecs_desired_capacity
  private_subnet_ids = module.network.private_subnet_ids
  ecs_sg_id         = module.network.ecs_sg_id
  environment       = var.environment
}

module "ecr" {
  source      = "./modules/ecr"
  repo_name   = "microservice"
}

module "secrets" {
  source      = "./modules/secrets"
  # the module creates/generates the DB password itself, so do NOT pass db_password here
  db_username = var.db_username
  # supply the RDS endpoint (the secrets module expects this for the secret host field)
  rds_endpoint = module.rds.endpoint
  environment = var.environment
}


module "rds" {
  source              = "./modules/rds"
  subnet_ids          = module.network.private_subnet_ids
  vpc_id              = module.network.vpc_id
  db_instance_class   = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  db_username         = var.db_username
  db_password         = module.secrets.db_password
  backup_retention    = var.backup_retention
  skip_final_snapshot = var.skip_final_snapshot
  environment         = var.environment
  private_sg_id       = module.network.private_sg_id
}

module "ecs_services" {
  source                = "./modules/ecs_services"
  cluster_id            = module.ecs_cluster.cluster_id
  cluster_name          = module.ecs_cluster.cluster_name
  alb_target_group_arns = module.alb.target_groups
  db_secret_arn         = module.secrets.secret_arn
  rds_endpoint          = module.rds.endpoint
  ecr_repo_url          = module.ecr.repository_url
  wordpress_port        = var.wordpress_port
  microservice_port     = var.microservice_port
  environment           = var.environment
}


module "ec2_demo" {
  source            = "./modules/ec2_demo"
  subnet_ids        = module.network.private_subnet_ids
  sg_id             = module.network.ecs_sg_id
  instance_count    = var.ec2_demo_count
  instance_type     = var.ec2_demo_type
  target_group_arns = module.alb.demo_target_groups
  instance_port     = var.instance_port
  docker_port       = var.docker_port

  # pass the environment down (required by the module)
  environment = var.environment
}

