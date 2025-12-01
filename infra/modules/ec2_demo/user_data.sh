#!/bin/bash
# user-data for demo EC2 instances (Amazon Linux 2)
# Terraform will substitute ${instance_port} and ${docker_port}.
# Any literal shell ${...} expansions must use $${...} to avoid Terraform interpolation.

set -eux

# update & install docker
yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker

# create a folder for app logs
mkdir -p /var/log/demo-app
chown ec2-user:ec2-user /var/log/demo-app

# Pull and run a demo container (replace image below as needed)
docker pull nginx:latest

# Stop any existing container with name demo-app
if docker ps -a --format '{{.Names}}' | grep -q '^demo-app$' ; then
  docker rm -f demo-app || true
fi

# Run the container mapping host ${instance_port} to container ${docker_port}
# Terraform will replace ${instance_port} and ${docker_port}.
docker run -d --name demo-app -p ${instance_port}:${docker_port} nginx:latest

# Example of a shell parameter expansion that must be evaluated at runtime:
# Use $${SOME_VAR:-default} so Terraform does not try to interpolate it.
echo "Runtime expansion example: $${SOME_VAR:-default}" > /var/log/demo-app/info.txt

echo "user-data finished" >> /var/log/demo-app/info.txt
