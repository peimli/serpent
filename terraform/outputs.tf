output "ec2_user_data" {
  value     = aws_instance.debian.user_data
}
output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.mysql.address
}
output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.mysql.port
}
output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.debian.public_ip
}
output "ec2_public_dns" {
  value = aws_instance.debian.public_dns
}
