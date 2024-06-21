provider "aws" {

  region = "us-east-1"

}
 
terraform {

  backend "s3" {

    bucket = "locoperro01" #s3 bucket name 

    key    = "path/to/terraform.tfstate"

    region = "us-east-1"

  }

}
 
# Crear una VPC

resource "aws_vpc" "main" {

  cidr_block           = "10.0.0.0/16"

  enable_dns_support   = true

  enable_dns_hostnames = true

}
 
# Crear una subred pública dentro de la VPC

resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.main.id

  cidr_block              = "10.0.1.0/24"

  map_public_ip_on_launch = true
 
  tags = {

    Name = "Public Subnet"

  }

}
 
# Crear una puerta de enlace de Internet (Internet Gateway) y conectarlo a la VPC

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.main.id
 
  tags = {

    Name = "Main VPC Gateway"

  }

}
 
# Conectar la subred pública a la puerta de enlace de Internet

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id
 
  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.gw.id

  }
 
  tags = {

    Name = "Public Route Table"

  }

}
 
resource "aws_route_table_association" "public" {

  subnet_id      = aws_subnet.public.id

  route_table_id = aws_route_table.public.id

}
 
# Crear un grupo de seguridad para la instancia EC2 en la VPC principal

resource "aws_security_group" "instance" {

  name = "terraform-example-instance2"

  ingress {

    from_port   = 80

    to_port     = 80

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }
 
  ingress {

    from_port   = 22

    to_port     = 22

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }
 
  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}
 
# Crear una instancia EC2 en la subred pública

resource "aws_instance" "example" {

  subnet_id         = aws_subnet.public.id

  ami               = "ami-08a0d1e16fc3f61ea"

  instance_type     = "t2.micro"

  key_name          = "vockey"

  vpc_security_group_ids = [aws_security_group.instance.id]
 
  user_data = <<-EOF

              #!/bin/bash

              sudo yum update -y && sudo yum upgrade -y

              sudo yum install nginx -y

              sudo systemctl start nginx

              sudo systemctl enable nginx

              EOF
 
 
  tags = {

    Name = "Alex1-example-instance"

  }

}
