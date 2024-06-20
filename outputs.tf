output "instance_public_ip" {
  value = aws_instance.example.public_ip
}

output "instance_public_dns" {
  value = aws_instance.example.public_dns
}

output "rds_instance_arn" {
  value = aws_db_instance.default.arn
}
