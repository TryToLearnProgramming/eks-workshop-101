locals {
  name            = "eks-terraform-workshop"
  cluster_version = "1.29"


  vpc_cidr        = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]


  tags = {
    OU          = "stx"
    BU          = "devops"
    PU          = "poc"
    Environment = "dev"
    Terraform   = "true"
  }
}
