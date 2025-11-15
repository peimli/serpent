variable "region" {
  description = "AWS region for deployment"
  type = string
}
variable "db_password" {
  description = "RDS root user password"
  type = string
}
variable "db_username" {
  description = "RDS root user name"
  type = string
}
variable "db_name" {
  description = "RDS DB name"
  type = string
}
variable "instance_type" {
  description = "The instance type of the machine!"
  type = string
}
variable "ami_id" {
  description = "The AMI ID of the machine!"
  type = string
}
variable "ami_name" {
  description = "The name of the AMI instance."
  type = string
}
variable "key_name" {
  description = "The name of the AWS ssh key!"
  type = string
}
variable "az" {
  description = "The availability zone"
  type = string
}

variable "my_bucket" {
  description = "The bucket for sql backup."
  type = string
}
