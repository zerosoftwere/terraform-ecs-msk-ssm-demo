resource "aws_iam_role" "cluster_role" {
  name               = "cluster-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_policy_doc.json
}

resource "aws_iam_instance_profile" "cluster_profile" {
  name = "cluster-profile"
  role = aws_iam_role.cluster_role.name
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs-service-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_policy_doc.json
}

resource "aws_iam_role" "ecs_consul_server_role" {
  name               = "ecs-consul-server-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_policy_doc.json
}


resource "aws_iam_policy_attachment" "ecs_service_attach" {
  name       = "ecs-service-attach"
  roles      = [aws_iam_role.ecs_service_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy" "cluster_policy" {
  name   = "cluster-policy"
  role   = aws_iam_role.cluster_role.id
  policy = data.aws_iam_policy_document.cluster_policy_doc.json
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json
}

resource "aws_iam_policy_attachment" "aws_ecs_task_execution_role" {
  name       = "aws-ecs-task-execution"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name   = "ecs-task-execution-attach"
  role   = aws_iam_role.ecs_task_execution_role.name
  policy = data.aws_iam_policy_document.task_execution_policy_doc.json
}
