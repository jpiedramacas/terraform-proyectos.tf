# EC2
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "example" {
  ami           = "ami-08a0d1e16fc3f61ea"
  instance_type = var.instance_type

  tags = {
    Name = "example-instance"
  }
}

# RDS
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0.37"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  apply_immediately    = true 
}

# VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# Subnet
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"  

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

