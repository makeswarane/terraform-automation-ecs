#!/bin/bash
echo "ECS_CLUSTER=${cluster}" > /etc/ecs/ecs.config
yum update -y
# Install CloudWatch Agent & SSM agent handled by AMI/policies
