data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# VPC Module
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "k8s-vpc"
  
  cidr                   = var.cidr_block
  azs                    = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets        = var.private_subnets
  public_subnets         = var.public_subnets
  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_egress_only_igw = false
  create_igw             = true

  manage_default_route_table    = false
  manage_default_security_group = false
  manage_default_network_acl    = false
  map_public_ip_on_launch       = false

}
