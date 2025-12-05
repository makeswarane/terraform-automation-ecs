module "network" {
  source          = "./modules/network"

  region          = var.region
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  environment     = var.environment
}


module "iam" {
  source      = "./modules/iam"
  environment = var.environment
  account_id  = var.account_id
  region      = var.region
}

module "ecr" {
  source     = "./modules/ecr"
  repo_names = ["microservice"]
}

module "secrets" {
  source      = "./modules/secrets"
  db_username = var.db_username
  db_password = var.db_password
  environment = var.environment
}

module "rds" {
  source                = "./modules/rds"
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  db_name               = var.db_name
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_username           = var.db_username
  db_password           = var.db_password      # 👈 NEW
  rds_security_group_id = module.network.rds_sg_id
  backup_retention      = var.backup_retention
  skip_final_snapshot   = var.skip_final_snapshot
  environment           = var.environment
}


module "ecs_cluster" {
  source               = "./modules/ecs_cluster"
  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  public_subnet_ids    = module.network.public_subnet_ids
  ecs_instance_type    = var.ecs_instance_type
  ecs_min_size         = var.ecs_min_size
  ecs_max_size         = var.ecs_max_size
  ecs_desired_capacity = var.ecs_desired_capacity
  iam_instance_profile = module.iam.ec2_instance_profile_name
  cluster_name         = var.ecs_cluster_name
  region               = var.region
  environment          = var.environment
}

module "ecs_services" {
  source            = "./modules/ecs_services"
  vpc_id            = module.network.vpc_id        # 👈 NEW
  cluster_name      = module.ecs_cluster.cluster_name
  private_subnet_ids = module.network.private_subnet_ids
  ecr_repo          = module.ecr.repo_urls["microservice"]
  rds_endpoint      = module.rds.db_address
  db_secret_arn     = module.secrets.db_secret_arn
  iam_task_role_arn = module.iam.ecs_task_role_arn
  alb_sg_id         = module.network.alb_sg_id
  region            = var.region
  environment       = var.environment
}

module "ec2_app" {
  source              = "./modules/ec2_app"
  private_subnet_ids  = module.network.private_subnet_ids
  iam_instance_profile = module.iam.ec2_instance_profile_name
  domain              = var.domain_name
  instance_count      = var.ec2_demo_count
  ec2_instance_type   = var.ec2_demo_type
  private_sg_id       = module.network.private_sg_id
  environment         = var.environment
}

module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.network.vpc_id      # 👈 NEW
  public_subnet_ids   = module.network.public_subnet_ids
  alb_certificate_arn = var.alb_certificate_arn
  domain              = var.domain_name
  alb_sg_id           = module.network.alb_sg_id

  tg_wordpress_arn = module.ecs_services.tg_wordpress_arn
  tg_micro_arn     = module.ecs_services.tg_micro_arn

  ec2_instance_ids = module.ec2_app.instance_ids
  ec2_docker_ids   = module.ec2_app.instance_ids
  environment      = var.environment
}
