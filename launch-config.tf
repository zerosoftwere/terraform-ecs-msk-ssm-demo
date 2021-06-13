resource "aws_launch_configuration" "ecs_launch_config" {
  name_prefix          = "ecs-launch-config"
  image_id             = var.ecs_ami[var.region]
  instance_type        = "t2.small"
  iam_instance_profile = aws_iam_instance_profile.cluster_profile.id
  key_name             = aws_key_pair.ssh_key.key_name
  security_groups = [
    aws_security_group.allow_all_out_sg.id,
    aws_security_group.allow_cluster_ports_sg.id,
    aws_security_group.database_sg.id
  ]
  user_data = <<-EOF
        #!/bin/bash
        echo 'ECS_CLUSTER=${aws_ecs_cluster.main_cluster.name}' > /etc/ecs/ecs.config
        start ecs
    EOF
  lifecycle {
    create_before_destroy = true
  }
}