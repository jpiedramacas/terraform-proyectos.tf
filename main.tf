provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "my-vpc"
  }
}

# Subnet Pública
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "my-igw"
  }
}

# Route Table Pública
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

# Asociación de Route Table Pública con Subnet Pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
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
    Name = "ec2-sg"
  }
}

# EC2 Instance
resource "aws_instance" "example" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "example-instance"
  }
}

# Variables
variable "aws_region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "The availability zone where the subnet will be created"
  type        = string
  default     = "us-east-1a"
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-08a0d1e16fc3f61ea"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.example.public_ip
}
