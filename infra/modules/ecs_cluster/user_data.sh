#!/bin/bash
# user-data for the ECS cluster launch template
# Terraform will substitute ${cluster_name}

set -eux

# install AWS CLI & ecs agent deps if needed
yum update -y
yum install -y aws-cli jq

# Amazon Linux 2 ECS agent install (example)
amazon-linux-extras install -y ecs
systemctl enable --now ecs

# Configure ECS cluster name in /etc/ecs/ecs.config
cat > /etc/ecs/ecs.config <<EOF
ECS_CLUSTER=${cluster_name}
# Example of escaping shell ${...} sequences for literal use:
# this line will contain a literal bash expression that should be evaluated at runtime:
MY_RUNTIME_VAR=\$${RUNTIME_VAR:-"default-val"}
EOF

# restart ECS agent to pick up config
systemctl restart ecs || true

echo "ecs user-data finished" > /var/log/ecs-user-data.log
