provider "aws" {
  region  = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "cyf_default_vpc"
  }
}

data "aws_availability_zones" "available_zones" {}

resource "aws_default_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  tags = {
    Name = "cyf_subnet_az1"
  }
}

resource "aws_default_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  tags = {
    Name = "cyf_subnet_az2"
  }
}

resource "aws_security_group" "webserver_security_group" {
  name        = "webserver_security_group"
  description = "Enable HTTP access on port 80"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cyf_webserver_security_group"
  }
}

resource "aws_security_group" "database_security_group" {
  name        = "database_security_group"
  description = "Enable PostgreSQL access on port 5432"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description      = "PostgreSQL access"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.webserver_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cyf_database_security_group"
  }
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "cyf_db_subnet_group"
  subnet_ids  = [aws_default_subnet.subnet_az1.id, aws_default_subnet.subnet_az2.id]
  description = "videorec db subnet groups"
}

resource "aws_db_instance" "db_instance" {
  engine            = "postgres"
  engine_version    = "12"
  multi_az          = false
  identifier        = "videorec"
  username          = var.db_username
  password          = var.db_password
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  skip_final_snapshot   = true
}