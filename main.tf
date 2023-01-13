// vpc main with cidr_block "10.0.0.0/16" and 2 subnets
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name    = "highly-available-wordpress-aws-vpc"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "vpc"
    Team    = "devops"
  }
}

// vpc public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"

  tags = {
    Name    = "public"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "vpc"
    Team    = "devops"
  }
}

// vpc private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name    = "private"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "vpc"
    Team    = "devops"
  }
}

// vpc private subnet 2
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2c"

  tags = {
    Name    = "private2"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "vpc"
    Team    = "devops"
  }
}

// vpc internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "highly-available-wordpress-aws-igw"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "vpc"
    Team    = "devops"
  }
}

// vpc route table public
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "highly-available-wordpress-aws-rtb"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "vpc"
    Team    = "devops"
  }
}

// vpc route table association
resource "aws_route_table_association" "rtb-association-public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rtb.id
}

// vpc elastic ip
resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name    = "highly-available-wordpress-aws-eip"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "vpc"
    Team    = "devops"
  }
}

// vpc nat gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name    = "highly-available-wordpress-aws-nat"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "vpc"
    Team    = "devops"
  }
}

// vpc route table private
resource "aws_route_table" "rtb-private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "highly-available-wordpress-aws-rtb-private"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "route-table"
    Team    = "devops"
  }
}

// security group for the public subnet
resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  description = "Allow inbound traffic from the internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow inbound traffic from the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "public-sg"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "security-group"
    Team    = "devops"
  }
}

// security group for mysql open to public-sg
resource "aws_security_group" "mysql-sg" {
  name        = "mysql-sg"
  description = "Allow inbound traffic from the public-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Allow inbound traffic from the public-sg"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public-sg.id]
  }

  egress {
    description = "Allow outbound traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "mysql-sg"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "security-group"
    Team    = "devops"
  }
}

// db_subnet_group_name 
resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private2.id]

  tags = {
    Name    = "db-subnet-group"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "db-subnet-group"
    Team    = "devops"
  }
}

// rds create database, mysql, dev/test, dbname = wordpress, burstable class = db.t2.micro, storage = 20gb, standby = 1, multi-az = true, vpc = aws_vpc.vpc.id, subnet = aws_subnet.private.id, security group = mysql-sg, db_subnet_group_name = db-subnet-group
resource "aws_db_instance" "db" {
  identifier              = "wordpress"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  multi_az                = true
  db_name                 = "wordpress"
  username                = "wordpress"
  password                = "wordpress"
  parameter_group_name    = "default.mysql5.7"
  vpc_security_group_ids  = [aws_security_group.mysql-sg.id]
  db_subnet_group_name    = aws_db_subnet_group.db-subnet-group.name
  backup_retention_period = 0
  apply_immediately       = true

  skip_final_snapshot = true

  tags = {
    Name    = "wordpress"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "db"
    Team    = "devops"
  }
}

// iam role for ec2 instance to access s3
resource "aws_iam_role" "ec2_wordpress_role" {
  name = "ec2_wordpress_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// ec2 instance profile
resource "aws_iam_instance_profile" "ec2_wordpress_profile" {
  name = "ec2_wordpress_profile"
  role = "${aws_iam_role.ec2_wordpress_role.name}"
}

// s3 full access policy
resource "aws_iam_role_policy" "s3_full_access_policy" {
  name = "s3_full_access_policy"
  role = "${aws_iam_role.ec2_wordpress_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


// amazon linux 2 instance using ec2_wordpress_role
resource "aws_instance" "wordpress" {
  ami           = "ami-084e8c05825742534"
  instance_type = "t2.micro"
  key_name      = "tutorials"
  subnet_id     = aws_subnet.public.id
  iam_instance_profile = "${aws_iam_instance_profile.ec2_wordpress_profile.name}"
  vpc_security_group_ids = [aws_security_group.public-sg.id]
  
  user_data = <<EOF
    #!/bin/bash
    yum update -y
    yum install amazon-linux-extras httpd -y 
    amazon-linux-extras install php7.2 -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd
    cd /var/www/html
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* /var/www/html/
    rm -rf wordpress
    rm -rf latest.tar.gz
    chmod -R 755 /var/www/html/*
    chown -R apache:apache /var/www/html/*
    wget https://s3.amazonaws.com/bucketforwordpresslab-donotdelete/htaccess.txt
    mv htaccess.txt .htaccess
    chkconfig httpd on
  EOF


  tags = {
    Name    = "wordpress"
    Service = "wordpress demo"
    Env     = "dev"
    Role    = "ec2"
    Team = "devops"
  }
}
