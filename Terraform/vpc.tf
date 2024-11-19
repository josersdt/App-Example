############################
# vpc.tf
############################
data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "test-app-vpc"
  cidr = var.vpc_cidr

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Dos subredes públicas y dos privadas
  public_subnets  = ["172.32.1.0/24", "172.32.2.0/24"]
  private_subnets = ["172.32.3.0/24", "172.32.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
