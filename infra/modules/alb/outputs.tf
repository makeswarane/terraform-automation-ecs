#output "dns_name"        { value = aws_lb.main.dns_name }
#output "target_groups" {
 # value = {
  #  wordpress    = aws_lb_target_group.wordpress.arn
   # microservice = aws_lb_target_group.microservice.arn
#  }
#}
#output "demo_target_groups" {
 # value = {
#    instance = aws_lb_target_group.instance.arn
  #  docker   = aws_lb_target_group.docker.arn
 # }
#}