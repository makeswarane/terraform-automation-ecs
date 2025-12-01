#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
cat > /home/ec2-user/Dockerfile <<'EOF'
FROM public.ecr.aws/amazonlinux/amazonlinux:2
RUN yum install -y httpd && echo "Hello from Container" > /var/www/html/index.html
EXPOSE 8080
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
EOF
docker build -t namaste:latest /home/ec2-user
docker run -d --name namaste -p 127.0.0.1:8080:80 namaste:latest
# nginx config to route instance.<domain> and docker.<domain> would be handled by ALB listeners
