resource "aws_iam_policy" "fluent_bit_cloudwatch" {
  name        = "${local.name}-FluentBitCloudWatch"
  description = "IAM policy for Fluent Bit to send logs to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "fluent_bit_eks" {
  name = "${local.name}-FluentBitEKS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:amazon-cloudwatch:fluent-bit"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit_cloudwatch_attach" {
  role       = aws_iam_role.fluent_bit_eks.name
  policy_arn = aws_iam_policy.fluent_bit_cloudwatch.arn
}

# resource "helm_release" "fluent_bit" {
#   name       = "fluent-bit"
#   repository = "https://fluent.github.io/helm-charts"
#   chart      = "fluent-bit"
#   namespace  = "amazon-cloudwatch"

#   set {
#     name  = "serviceAccount.name"
#     value = "fluent-bit"
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.fluent_bit_eks.arn
#   }

#   values = [<<-EOF
#     rawConfig: |
#       [FILTER]
#           Name    kubernetes
#           Match   kube.*
#           Kube_URL https://kubernetes.default.svc:443
#     config:
#       outputs:
#         - name: cloudwatch_logs
#           match: "*"
#           region: ${data.aws_region.current.name}
#           log_group_name: "/aws/eks/fluent-bit/logs"
#           log_stream_prefix: "fluent-bit-"
#           auto_create_group: true
#     EOF
#   ]
# }

resource "helm_release" "aws_for_fluent_bit" {
  name       = "aws-for-fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = "amazon-cloudwatch"

  set {
    name  = "serviceAccount.name"
    value = "aws-for-fluent-bit"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.fluent_bit_eks.arn
  }

  values = [<<-EOF
    serviceAccount:
      create: true
      name: aws-for-fluent-bit
      annotations:
        eks.amazonaws.com/role-arn: "${aws_iam_role.fluent_bit_eks.arn}"
    config:
      outputs:
        - name: cloudwatch_logs
          match: "*"
          region: "${data.aws_region.current.name}"
          log_group_name: "/aws/eks/fluent-bit/logs"
          log_stream_prefix: "fluent-bit-"
          auto_create_group: true
    EOF
  ]
}

resource "helm_release" "cloudwatch_agent" {
  name       = "cloudwatch-agent"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-cloudwatch-metrics"
  namespace  = "amazon-cloudwatch"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "cloudwatch-agent"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "configmap.agent.interval"
    value = "60s"
  }

  set {
    name  = "configmap.agent.metrics_collected.statsd"
    value = "true"
  }

  set {
    name  = "configmap.agent.metrics_collected.statsd.service_address"
    value = ":8125"
  }

  set {
    name  = "configmap.agent.metrics_collected.statsd.metrics_aggregation_interval"
    value = "60s"
  }

  # Specify additional configurations as needed
}

# resource "kubernetes_namespace" "cloudwatch" {
#   metadata {
#     name = "amazon-cloudwatch"
#   }
# }
