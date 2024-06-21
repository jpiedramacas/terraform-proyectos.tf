provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-12345678" # Reemplaza con una AMI válida
  instance_type = "t2.micro"
  tags = {
    Name = "example-instance"
  }
}
