mkdir -p terraform-automation-ecs-main/terraform-automation-ecs-main/infra/modules/ecs_cluster
cat > terraform-automation-ecs-main/terraform-automation-ecs-main/infra/modules/ecs_cluster/user_data.sh <<'EOF'
#!/bin/bash
# user-data for ECS cluster nodes (Amazon Linux 2)
# Terraform will substitute ${cluster_name}.
# Escape any literal shell ${...} with $${...}.

set -eux

yum update -y
yum install -y aws-cli jq

amazon-linux-extras enable ecs
yum install -y ecs

cat > /etc/ecs/ecs.config <<EOC
ECS_CLUSTER=${cluster_name}
# example runtime-only expansion (escaped)
MY_RUNTIME_VAR=$${RUNTIME_VAR:-"default-val"}
EOC

systemctl enable --now ecs || true

echo "ecs user-data finished" > /var/log/ecs-user-data.log
EOF

chmod +x terraform-automation-ecs-main/terraform-automation-ecs-main/infra/modules/ecs_cluster/user_data.sh
