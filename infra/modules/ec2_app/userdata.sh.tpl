#!/bin/bash
set -e
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user

cat <<'DOCKERFILE' > /tmp/Dockerfile
FROM nginx:alpine
RUN mkdir -p /usr/share/nginx/html
RUN echo 'Namaste from Container' > /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

docker build -t namaste-img /tmp
docker run -d --name namaste -p 8080:80 namaste-img

yum install -y nginx
cat >/etc/nginx/conf.d/site.conf <<NGINX
server {
    listen 80;
    server_name instance.${domain};
    location / { add_header Content-Type text/plain; return 200 'Hello from Instance'; }
}
server {
    listen 80;
    server_name ec2-docker.${domain};
    location / { proxy_pass http://127.0.0.1:8080; proxy_set_header Host $host; }
}
NGINX
systemctl enable --now nginx

yum install -y awslogs
cat >/etc/awslogs/awslogs.conf <<AWSLOGS
[general]
state_file = /var/lib/awslogs/agent-state
[/var/log/nginx/access.log]
file = /var/log/nginx/access.log
log_group_name = /ec2/nginx/access
log_stream_name = {instance_id}
AWSLOGS

systemctl enable --now awslogsd
