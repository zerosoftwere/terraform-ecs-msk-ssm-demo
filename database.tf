
resource "random_string" "database_password" {
  length = 16
}

resource "aws_db_instance" "main_database" {
  allocated_storage       = 50
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "10.15"
  instance_class          = "db.t2.micro"
  name                    = "main_db"
  identifier              = "main-db"
  username                = "postgres"
  publicly_accessible     = false
  password                = random_string.database_password.result
  vpc_security_group_ids  = [aws_security_group.database_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.database_subnet.name
  backup_retention_period = "30"
  skip_final_snapshot     = true

  tags = {
    Name = "main database"
  }
}

resource "aws_db_subnet_group" "database_subnet" {
  name       = "main-database-subnet"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  tags = {
    Name = "main-database-subnet"
  }
}

resource "aws_ssm_parameter" "database_username" {
  name      = "/app/database/username"
  type      = "String"
  value     = aws_db_instance.main_database.username
  overwrite = true
}

resource "aws_ssm_parameter" "database_password" {
  name      = "/app/database/password"
  type      = "String"
  value     = random_string.database_password.result
  overwrite = true
}

resource "aws_ssm_parameter" "database_endpoint" {
  name      = "/app/database/endpoint"
  type      = "String"
  value     = aws_db_instance.main_database.endpoint
  overwrite = true
}

resource "aws_ssm_parameter" "database_name" {
  name      = "/app/database/name"
  type      = "String"
  value     = aws_db_instance.main_database.name
  overwrite = true
}

output "database_username" {
  value = aws_db_instance.main_database.username
}

output "database_password" {
  value = random_string.database_password.result
}

output "database_endpoint" {
  value = aws_db_instance.main_database.endpoint
}
