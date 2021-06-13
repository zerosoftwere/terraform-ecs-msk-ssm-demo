resource "aws_ecs_cluster" "main_cluster" {
  name = "cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    "Name" = "cluster"
  }
}