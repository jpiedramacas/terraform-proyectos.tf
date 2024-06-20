variable "aws_region" {
  description = "AWS region where resources will be created."
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Type of instance to create."
  type        = string
  default     = "t2.micro"
}
