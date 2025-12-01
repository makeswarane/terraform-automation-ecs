resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.project}-${var.environment}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume.json
}

data "aws_iam_policy_document" "ecs_instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = "${var.project}-${var.environment}-ecs-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "secrets_read" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

output "ecs_instance_profile_name" { value = aws_iam_instance_profile.ecs_profile.name }
output "ecs_task_role_arn" { value = aws_iam_role.ecs_task_role.arn }
