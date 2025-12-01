mkdir -p terraform-automation-ecs-main/terraform-automation-ecs-main/infra/modules/ec2_demo
cat > terraform-automation-ecs-main/terraform-automation-ecs-main/infra/modules/ec2_demo/user_data.sh <<'EOF'
#!/bin/bash
# user-data for demo EC2 instances (Amazon Linux 2)
# Terraform will substitute ${instance_port} and ${docker_port}.
# Any literal shell ${...} expansions must use $${...} so Terraform leaves them alone.

set -eux

yum update -y
yum install -y docker
systemctl enable --now docker

mkdir -p /var/log/demo-app
chown ec2-user:ec2-user /var/log/demo-app

docker pull nginx:latest

if docker ps -a --format '{{.Names}}' | grep -q '^demo-app$' ; then
  docker rm -f demo-app || true
fi

# Terraform will replace ${instance_port} and ${docker_port} at template time.
docker run -d --name demo-app -p ${instance_port}:${docker_port} nginx:latest

# Example runtime-only shell expansion (escaped so Terraform won't parse it)
echo "Runtime expansion example: $${SOME_VAR:-default}" > /var/log/demo-app/info.txt

echo "user-data finished" >> /var/log/demo-app/info.txt
EOF

chmod +x terraform-automation-ecs-main/terraform-automation-ecs-main/infra/modules/ec2_demo/user_data.sh
