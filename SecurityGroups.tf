# // aws security group webdmz
# resource "aws_security_group" "webDMZ" {
#   name        = "webDMZ"
#   description = "Allow inbound traffic from the internet to the web servers"
#   vpc_id      = aws_vpc.vpc.id

#   // ingress on http
#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   // ingress on https
#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   // ingress on ssh
#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   // egress all ports all protocols
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   } 

#   tags = {
#     Name    = "webDMZ"
#     Service = "wordpress demo"
#     Env     = "dev"
#     Role    = "security group"
#     Team    = "devops"
#   }  
# }

# // aws security group db aurora with source security group webDMZ
# resource "aws_security_group" "dbAurora" {
#   name        = "dbAurora"
#   description = "Allow inbound traffic from the web servers to the database"
#   vpc_id      = aws_vpc.vpc.id

#   // ingress on mysql
#   ingress {
#     description      = "MySQL"
#     from_port        = 3306
#     to_port          = 3306
#     protocol         = "tcp"
#     security_groups  = [aws_security_group.webDMZ.id]
#   }

#   // egress all ports all protocols
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name    = "dbAurora"
#     Service = "wordpress demo"
#     Env     = "dev"
#     Role    = "security group"
#     Team    = "devops"
#   }
# }

# resource "aws_vpc" "vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   tags = {
#     Name    = "highly-available-wordpress-aws-vpc"
#     Service = "wordpress demo"
#     Env     = "dev"
#     Role    = "vpc"
#     Team    = "devops"
#   }
# }

# // db subnet group in aws_vpc.vpc with 2 subnets
# resource "aws_db_subnet_group" "dbSubnetGroup" {
#   name       = "my-default"
#   subnet_ids = aws_subnet.subnet.*.id

#   tags = {
#     Name    = "my-default"
#     Service = "wordpress demo"
#     Env     = "dev"
#     Role    = "db subnet group"
#     Team    = "devops"
#   }
# }



# // rds create database mysql dev/test burstable t2.micro multi az not publicly accessible initial database wordpress
# # resource "aws_db_instance" "db" {
# #   identifier              = "wordpress"
# #   engine                  = "mysql"
# #   # engine_version          = "5.7.mysql_aurora.2.07.2"
# #   instance_class          = "db.m5.large"
# #   allocated_storage       = 20
# #   storage_type            = "gp2"
# #   name                    = "wordpress"
# #   username                = "wordpress"
# #   password                = "wordpress"
# #   db_subnet_group_name    = "my-default"
# #   vpc_security_group_ids  = [aws_security_group.dbAurora.id]
# #   multi_az                = true
# #   publicly_accessible     = false
# #   backup_retention_period = 0
# #   apply_immediately       = true
# #   tags = {
# #     Name    = "wordpress"
# #     Service = "wordpress demo"
# #     Env     = "dev"
# #     Role    = "rds"
# #     Team    = "devops"
# #   }
# # }
