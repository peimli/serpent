data "aws_availability_zones" "available" {}

######################################################
# VPC
######################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "education"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

######################################################
# Security Groups
######################################################
# EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

# RDS Security Group (only allow EC2 SG)
resource "aws_security_group" "rds_sg" {
  name   = "rds-mysql-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

######################################################
# RDS
######################################################
resource "aws_db_subnet_group" "education" {
  name       = "education"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Education"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "tf-mysql-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20

  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name

  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.education.name

  tags = {
    Name = "education-db"
  }
}


######################################################
# EC2 Instance
######################################################
resource "aws_instance" "debian" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  key_name               = var.key_name

  tags = {
    Name = "debian-serpent-surge-ansible"
  }
user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y default-mysql-client
              mysql -h ${aws_db_instance.mysql.address} \
                    -P 3306 \
                    -u ${var.db_username} \
                    -p${var.db_password} \
                    -e "CREATE DATABASE IF NOT EXISTS serpent;
                        USE serpent;
                        CREATE TABLE IF NOT EXISTS scores (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          name VARCHAR(255) NOT NULL,
                          score INT NOT NULL,
                          difficulty INT NOT NULL,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                        );"
              EOF
}

######################################################
# Existing S3 bucket access
######################################################

data "aws_s3_bucket" "existing_bucket" {
  bucket = var.my_bucket
}


resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "s3_access" {
  name = "s3-access-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          data.aws_s3_bucket.existing_bucket.arn,
          "${data.aws_s3_bucket.existing_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
