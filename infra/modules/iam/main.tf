# Assume role policy for ECS tasks
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Execution role (for pulling images, logs, etc.)
resource "aws_iam_role" "ecs_task_execution_role" {
  # Keep core name (no conflict reported for this)
  name               = "${var.environment}-ecs-task-exec-core"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role (for app-level permissions like Secrets Manager)
resource "aws_iam_role" "ecs_task_role" {
  # Keep core name (no conflict reported for this)
  name               = "${var.environment}-ecs-task-role-core"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_policy" "ecs_task_secrets_policy" {
  # ✅ New name to avoid existing free-ecs-secrets-core
  name = "${var.environment}-ecs-secrets-managed"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_secrets_policy.arn
}

# Assume role policy for EC2 instances
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# EC2 instance role (for SSM, logs, ECR read)
resource "aws_iam_role" "ec2_instance_role" {
  # ✅ New name to avoid existing free-ec2-instance-role-core
  name               = "${var.environment}-ec2-instance-role-managed"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# EC2 instance profile (name was not conflicting, so we keep it)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile-core"
  role = aws_iam_role.ec2_instance_role.name
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}
