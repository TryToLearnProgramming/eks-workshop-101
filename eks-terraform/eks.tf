module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.6.0"


  cluster_name    = local.name
  cluster_version = local.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size = 50
  }


  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true



  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }

    # spot = {
    #   desired_size = 1
    #   min_size     = 1
    #   max_size     = 10

    #   labels = {
    #     role = "spot"
    #   }

    #   taints = [{
    #     key    = "market"
    #     value  = "spot"
    #     effect = "NO_SCHEDULE"
    #   }]

    #   instance_types = ["t3.micro"]
    #   capacity_type  = "SPOT"
    # }
  }





  #   manage_aws_auth_configmap = true
  #   aws_auth_roles = [
  #     {
  #       rolearn  = module.eks_admins_iam_role.iam_role_arn
  #       username = module.eks_admins_iam_role.iam_role_name
  #       groups   = ["system:masters"]
  #     },
  #   ]

  #   node_security_group_additional_rules = {
  #     ingress_allow_access_from_control_plane = {
  #       type                          = "ingress"
  #       protocol                      = "tcp"
  #       from_port                     = 9443
  #       to_port                       = 9443
  #       source_cluster_security_group = true
  #       description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
  #     }
  #   }

  tags = {
    Environment = "dev"
  }
}

# Output the EKS cluster ARN
output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.eks.cluster_arn
}

# Output the EKS cluster certificate authority data
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = module.eks.cluster_certificate_authority_data
}

# Output the EKS cluster endpoint
output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

# Output the EKS cluster ID
output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks.cluster_id
}

# Output the EKS cluster name
output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

# Output the EKS cluster OIDC issuer URL
output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider."
  value       = module.eks.cluster_oidc_issuer_url
}

# Output the EKS cluster version
output "cluster_version" {
  description = "The Kubernetes version for the cluster."
  value       = module.eks.cluster_version
}

# Output the EKS cluster primary security group ID
output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster."
  value       = module.eks.cluster_primary_security_group_id
}

# Output the EKS cluster security group ID
output "cluster_security_group_id" {
  description = "ID of the cluster security group."
  value       = module.eks.cluster_security_group_id
}

# Output the EKS managed node groups
output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created."
  value       = module.eks.eks_managed_node_groups
}

# Output the EKS managed node groups autoscaling group names
output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups."
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}


# Output the EKS managed node groups autoscaling group names
output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks.oidc_provider
}



