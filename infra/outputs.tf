output "alb_dns_name" {
  value = module.alb.dns_name
}

output "wordpress_url" {
  value = "https://wordpress.${var.domain_name}"
}