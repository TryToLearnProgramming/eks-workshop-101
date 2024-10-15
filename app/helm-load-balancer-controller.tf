# data "http" "alb_ingress_policy" {
#   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json"

#   # Optional: If the server does not have a valid SSL certificate
#   # request_headers = {
#   #   "User-Agent" = "Terraform"
#   # }

#   request_headers = {
#     Accept = "application/json"
#   }

# }

# resource "aws_iam_policy" "alb_ingress" {
#   name        = "ALBIngressControllerIAMPolicy"
#   description = "IAM policy for ALB Ingress Controller"
#   policy      = data.http.alb_ingress_policy.response_body
# }



# resource "aws_iam_role" "aws_load_balancer_controller" {
#   name = "aws-load-balancer-controller"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.default.identity[0].oidc[0].issuer, "https://", "")}"
#         }
#         Condition = {
#           StringEquals = {
#             "${replace(data.aws_eks_cluster.default.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#           }
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "alb_ingress" {
#   role       = aws_iam_role.aws_load_balancer_controller.name
#   policy_arn = aws_iam_policy.alb_ingress.arn
# }



# Failed deploy model due to AccessDenied: User: arn:aws:sts::590183983509:assumed-role/aws-load-balancer-controller/1711739726644663973 is not authorized to perform: elasticloadbalancing:AddTags on resource: arn:aws:elasticloadbalancing:us-east-1:590183983509:targetgroup/k8s-default-cartapis-d7eae944ea/* because no identity-based policy allows the elasticloadbalancing:AddTags action status code: 403, request id: 39618f3d-b09c-4b8f-a363-047f28fce23f



module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.1"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}



resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.4"

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }
}



