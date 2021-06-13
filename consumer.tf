locals {
  consumer = "consumer.${var.domain}"
}

resource "aws_ecr_repository" "consumer" {
  name = "consumer"

  tags = {
    Name = "consumer"
  }
}


resource "aws_ecs_task_definition" "consumer_td" {
  family             = "consumer"
  cpu                = 512
  memory             = 512
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<-EOF
  [
    {
      "essential": true,
      "name": "consumer",
      "image": "${aws_ecr_repository.consumer.repository_url}",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
      ],
      "secrets": [
        {
          "name": "DB_USER",
          "valueFrom": "${aws_ssm_parameter.database_username.arn}"
        },
        {
          "name": "DB_PASS",
          "valueFrom": "${aws_ssm_parameter.database_password.arn}"
        },
        {
          "name": "DB_HOST",
          "valueFrom": "${aws_ssm_parameter.database_endpoint.arn}"
        },
        {
          "name": "DB_NAME",
          "valueFrom": "${aws_ssm_parameter.database_name.arn}"
        },
        {
            "name": "KAFKA_BOOSTRAP_SERVERS",
            "valueFrom": "${aws_ssm_parameter.bootstrap_servers.arn}"
        }
      ],
      "healthCheck": {
        "command": [
          "CMD-SHELL", "curl -f http://localhost:8080/q/health || exit 1"
        ],
        "interval": 60,
        "timeout": 15,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
  EOF
}

resource "aws_ecs_service" "consumer_service" {
  name            = "consumer"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.consumer_td.arn
  desired_count   = 1

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.consumer_tg.arn
    container_name   = "consumer"
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener_rule.consumer_lr
  ]
}

resource "aws_lb_target_group" "consumer_tg" {
  vpc_id   = aws_vpc.main_vpc.id
  name     = "consumer"
  protocol = "HTTP"
  port     = 80

  health_check {
    enabled             = true
    path                = "/q/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "consumer"
  }
}

resource "aws_route53_record" "consumer" {
  zone_id = data.aws_route53_zone.main_domain.zone_id
  name    = local.consumer
  type    = "A"

  alias {
    name                   = aws_lb.main_lb.dns_name
    zone_id                = aws_lb.main_lb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener_rule" "consumer_lr" {
  listener_arn = aws_lb_listener.main_https.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consumer_tg.arn
  }

  condition {
    host_header {
      values = [local.consumer]
    }
  }
}