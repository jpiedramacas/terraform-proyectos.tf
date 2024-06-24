provider "aws" {
  region = var.aws_region
}
 
# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
 
  tags = {
    Name = "My-VPC"
  }
}
 
# Subnets Públicas
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
 
  tags = {
    Name = "SubnetPublico-${count.index}"
  }
}
 
# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
 
  tags = {
    Name = "Internet-Gateway"
  }
}
 
# Route Table Pública Principal
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
 
  tags = {
    Name = "public-route-table"
  }
}
 
# Asociación de Route Table Pública Principal con Subnet Pública
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}
 
# Security Group
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.this.id
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
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
    Name = "ec2-SecurityGroup"
  }
}
 
# Instancia EC2
resource "aws_instance" "MY-EC2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[0].id  # Seleccionamos la primera subred pública
  key_name               = "vockey"  # Asegúrate de que este nombre coincida con la clave SSH existente en AWS
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
 
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y && sudo yum upgrade -y
    sudo yum install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF
 
  tags = {
    Name = "MY-EC2"
  }
}