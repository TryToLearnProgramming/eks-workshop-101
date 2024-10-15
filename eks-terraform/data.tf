# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009
# data "aws_eks_cluster" "default" {
#   name = module.eks.cluster_name
# }

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
