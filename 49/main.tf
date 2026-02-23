provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "my_vpc"
  cidr   = "10.0.0.0/16"
  azs    = ["eu-central-1a"]
  public_subnets = ["10.0.101.0/24"]
}
module "ec2" {
  source = "./app_server"
  sg_from_module = [module.vpc.default_security_group_id]
  subnet_from_module = module.vpc.public_subnets[0]
}
