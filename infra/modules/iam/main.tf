##################################
# IAM for ECS & EC2
##################################

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
  # name_prefix so AWS appends a unique suffix
  name_prefix        = "${var.environment}-ecs-task-exec-"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role (for app-level permissions like Secrets Manager)
resource "aws_iam_role" "ecs_task_role" {
  # also name_prefix to avoid collisions
  name_prefix        = "${var.environment}-ecs-task-role-"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_policy" "ecs_task_secrets_policy" {
  # IMPORTANT: name_prefix instead of fixed name
  name_prefix = "${var.environment}-ecs-secrets-"

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

##################################
# IAM for EC2 instances
##################################

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

# EC2 instance role (for SSM, logs, ECS, ECR read)
resource "aws_iam_role" "ec2_instance_role" {
  # name_prefix so we never clash again
  name_prefix        = "${var.environment}-ec2-instance-role-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# SSM
resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ECR read-only
resource "aws_iam_role_policy_attachment" "ec2_ecr_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# CloudWatch agent
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ✅ ECS instance role policy (this is the missing one)
resource "aws_iam_role_policy_attachment" "ec2_ecs_instance_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# EC2 instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  # name_prefix; AWS will generate a unique final name
  name_prefix = "${var.environment}-ec2-profile-"
  role        = aws_iam_role.ec2_instance_role.name
}
