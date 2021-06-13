resource "aws_security_group" "allow_all_out_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow all outgoing"
  name        = "allow-all-outgoing-sg"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
  }

  tags = {
    "Name" = "allow-all-outgoing-sg"
  }
}

resource "aws_security_group" "allow_all_in_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow all incoming"
  name        = "allow-all-incoming-sg"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
  }

  tags = {
    "Name" = "allow-all-incoming-sg"
  }
}

resource "aws_security_group" "allow_ssh_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "allow-ssh-sg"
  description = "Allow SSH"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  tags = {
    "Name" = "allow-ssh-sg"
  }
}

resource "aws_security_group" "allow_cluster_ports_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "allow-cluster-ports-sg"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }

  tags = {
    Name = "allow-cluster-ports-sg"
  }
}

resource "aws_security_group" "allow_https_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "allow-https-sg"
  description = "Allow HTTPS"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
  }

  tags = {
    "Name" = "allow-https-sg"
  }
}

resource "aws_security_group" "database_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "main-db-sg"

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    self      = true
  }

  tags = {
    Name = "main-db-sg"
  }
}