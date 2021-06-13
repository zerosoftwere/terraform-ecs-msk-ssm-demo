resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                      = "ecs-autoscaling-group"
  vpc_zone_identifier       = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
  launch_configuration      = aws_launch_configuration.ecs_launch_config.name
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 60
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "ecs-autoscaling-group"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.ecs_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.ecs_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_sns_topic" "scale_sns_topic" {
  name         = "scale-notification"
  display_name = "scale notification"
}

resource "aws_autoscaling_notification" "scale_notification" {
  group_names = [aws_autoscaling_group.ecs_autoscaling_group.name]
  topic_arn   = aws_sns_topic.scale_sns_topic.arn

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_scale_up_alarm" {
  alarm_name          = "cpu-scale-up-alarm"
  alarm_description   = "scale up alarm on limited cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 70
  statistic           = "Average"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = 120
  actions_enabled     = true

  alarm_actions = [
    aws_autoscaling_policy.scale_up_policy.arn
  ]

  dimensions = {
    ClusterName = aws_ecs_cluster.main_cluster.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_scale_down_alarm" {
  alarm_name          = "cpu-scale-down-alarm"
  alarm_description   = "scale down alarm on excess cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 25
  statistic           = "Average"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = 120
  actions_enabled     = true

  alarm_actions = [
    aws_autoscaling_policy.scale_down_policy.arn
  ]

  dimensions = {
    ClusterName = aws_ecs_cluster.main_cluster.name
  }
}
