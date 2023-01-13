// vpc with cidr 10.0.0.0/24
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
