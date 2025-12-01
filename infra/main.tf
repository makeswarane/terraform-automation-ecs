# Top-level composition of modules

module "network" {
  source = "./modules/network"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags = var.tags
}

module "iam" {
  source = "./modules/iam"
  project = var.project
  environment = var.environment
  tags = var.tags
}

module "ecr" {
  source = "./modules/ecr"
  name = var.ecr_microservice_name
  tags = var.tags
}

module "secrets" {
  source = "./modules/secrets"
  db_username = var.db_username
  create_secret = var.enable_rds
  tags = var.tags
}

module "rds" {
  source = "./modules/rds"
  enable = var.enable_rds
  db_engine = var.db_engine
  db_instance_class = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name = var.db_name
  subnet_ids = module.network.private_subnets
  secret_arn = module.secrets.secret_arn
  tags = var.tags
  depends_on = [module.network]
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"
  cluster_name = var.cluster_name
  vpc_id = module.network.vpc_id
  private_subnets = module.network.private_subnets
  iam_instance_profile = module.iam.ecs_instance_profile_name
  ecs_instance_type = var.ecs_instance_type
  ecs_min = var.ecs_instance_min
  ecs_desired = var.ecs_instance_desired
  ecs_max = var.ecs_instance_max
  tags = var.tags
}

module "ecs_services" {
  source = "./modules/ecs_services"
  cluster_name = module.ecs_cluster.cluster_name
  public_subnets = module.network.public_subnets
  private_subnets = module.network.private_subnets
  ecr_repo_uri = module.ecr.repository_url
  microservice_port = var.microservice_container_port
  wordpress_image = var.wordpress_image
  wordpress_port = var.wordpress_container_port
  secret_arn = module.secrets.secret_arn
  tags = var.tags
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.network.vpc_id
  public_subnets = module.network.public_subnets
  domain = var.domain
  acm_certificate_arn = var.acm_certificate_arn
  tags = var.tags
  services = module.ecs_services.service_map
}

module "ec2_app" {
  source = "./modules/ec2_app"
  create = var.create_ec2_app
  count = var.ec2_app_count
  instance_type = var.ec2_app_instance_type
  private_subnets = module.network.private_subnets
  domain = var.domain
  tags = var.tags
}

module "monitoring" {
  source = "./modules/monitoring"
  log_prefix = "${var.project}-${var.environment}"
}
