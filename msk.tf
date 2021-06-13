resource "aws_security_group" "msk_sg" {
  name   = "msk-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    "Name" = "MSK sg"
  }
}

resource "aws_msk_configuration" "main_config" {
  kafka_versions = ["2.6.1"]
  name           = "main-config"

  server_properties = <<PROP
auto.create.topics.enable = true
delete.topic.enable = true
  PROP
}

resource "aws_msk_cluster" "main" {
  cluster_name           = "main"
  kafka_version          = "2.6.1"
  number_of_broker_nodes = 2
  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    ebs_volume_size = 100
    client_subnets = [
      aws_subnet.subnet_1.id,
      aws_subnet.subnet_2.id
    ]
    security_groups = [aws_security_group.msk_sg.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = null

    encryption_in_transit {
      client_broker = "PLAINTEXT"
      in_cluster    = false
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.main_config.arn
    revision = aws_msk_configuration.main_config.latest_revision
  }
}

resource "aws_ssm_parameter" "bootstrap_servers" {
  name  = "/app/kafka/bootstrap_servers"
  type  = "String"
  value = aws_msk_cluster.main.bootstrap_brokers
}

output "bootstrap_servers" {
  value = aws_msk_cluster.main.bootstrap_brokers
}