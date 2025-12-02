data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service"; identifiers = ["ecs-tasks.amazonaws.com"] }
  }
}
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-ecs-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}
resource "aws_iam_policy" "ecs_task_secrets_policy" {
  name = "${var.environment}-ecs-secrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["secretsmanager:GetSecretValue"], Resource = "*" },
      { Effect = "Allow", Action = ["ecr:GetAuthorizationToken","ecr:BatchGetImage","ecr:GetDownloadUrlForLayer"], Resource = "*" },
      { Effect = "Allow", Action = ["logs:CreateLogStream","logs:PutLogEvents"], Resource = "*" }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_role_attach" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_secrets_policy.arn
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service"; identifiers = ["ec2.amazonaws.com"] }
  }
}
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.environment}-ec2-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}
resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "ec2_ecr_attach" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_attach" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_instance_role.name
}

output "ecs_task_role_arn" { value = aws_iam_role.ecs_task_role.arn }
output "ecs_task_execution_role_arn" { value = aws_iam_role.ecs_task_execution_role.arn }
output "ec2_instance_profile_name" { value = aws_iam_instance_profile.ec2_profile.name }
