#cluster-node
data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

#worker node
data "aws_iam_policy_document" "worker_assume_role_policy" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "alb_ingress" {
  count = local.alb_ingress_count
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags",
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:ModifyRule",
      "tag:GetResources",
      "tag:TagResources",
      "waf:GetWebACL"
    ]

    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      values   = ["CreateSecurityGroup"]
      variable = "ec2:CreateAction"
    }
    condition {
      test     = "Null"
      values   = ["false"]
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
    }
    resources = ["arn:aws:ec2:*:*:security-group/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:DeleteTargetGroup"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    condition {
      test     = "Null"
      values   = ["aws:RequestTag/elbv2.k8s.aws/cluster"]
      variable = "true"
    }
    condition {
      test     = "Null"
      values   = ["aws:ResourceTag/elbv2.k8s.aws/cluster"]
      variable = "false"
    }
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets"
    ]
    resources = ["arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"]
  }

  dynamic "statement" {
    for_each = var.create_service_accounts_role ? [] : [1]
    content {
      effect = "Allow"
      actions = [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets"
      ]
      resources = ["*"]
    }
  }
}

#cloudwatch logs
data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    sid = "CloudwatchPutMetricData"

    actions = ["cloudwatch:PutMetricData"]

    resources = ["*"]
  }

  statement {
    sid = "InstanceLogging"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "cluster_eks" {
  name                  = format("%s-iamrole", var.eks_cluster_name)
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_eks.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_eks.name
}

#Worker Node
resource "aws_iam_role" "worker_eks" {
  name               = format("%s-worker-iamrole", var.eks_cluster_name)
  assume_role_policy = data.aws_iam_policy_document.worker_assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name   = format("%s-cloudwatch-instance-policy", var.eks_cluster_name)
  path   = "/"
  policy = data.aws_iam_policy_document.cloudwatch_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_eks.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_eks.name
}

resource "aws_iam_role_policy_attachment" "eks_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_eks.name
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_policy" {
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
  role       = aws_iam_role.worker_eks.name
}
resource "aws_iam_instance_profile" "eks-worker-profile" {
  name = format("%s-worker-profile", var.eks_cluster_name)
  role = aws_iam_role.worker_eks.name
}
resource "aws_iam_policy" "alb_ingress_policy" {
  count  = local.alb_ingress_count
  policy = data.aws_iam_policy_document.alb_ingress[count.index].json
  name   = format("%s-elb-alb-ingress-policy", var.eks_cluster_name)
}
resource "aws_iam_role_policy_attachment" "eks_ingress_alb_policy_attach" {
  count      = local.alb_ingress_count
  policy_arn = aws_iam_policy.alb_ingress_policy[count.index].arn
  role       = aws_iam_role.worker_eks.name
}


# ALB log bucket policy
data "aws_elb_service_account" "elb_account" {}

data "aws_iam_policy_document" "alb_s3_bucket_policy" {
  count = local.alb_ingress_count
  statement {
    sid = "S3BucketPolicy"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.elb_account.arn]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      var.alb_log_bucket_name != null ? format("arn:aws:s3:::%s-alb-log-bucket/*", var.alb_log_bucket_name) : format("arn:aws:s3:::%s-alb-log-bucket/*", terraform.workspace)

    ]
  }
}

// OIDC Policy and Service Accounts

resource "aws_iam_openid_connect_provider" "eks_openid_provider" {
  count           = var.create_service_accounts_role ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.thumbprint_list]
  url             = aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer
  depends_on      = [aws_eks_cluster.ekscluster]
}

data "aws_iam_policy_document" "eks_role_oidc_policy" {
  count = var.create_service_accounts_role ? 1 : 0
  statement {
    sid     = "ekswebidentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = [format("arn:aws:iam::%s:oidc-provider/%s", data.aws_caller_identity.current.account_id, replace(aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer, "https://", ""))]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
      variable = format("%s:sub", replace(aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer, "https://", ""))
    }
  }
}

resource "aws_iam_role" "sa_alb_role" {
  count                 = var.create_service_accounts_role ? 1 : 0
  name                  = format("%s-sa-alb-role", aws_eks_cluster.ekscluster.name)
  description           = "Permissions required by the Kubernetes AWS ALB Ingress controller to do it's job."
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.eks_role_oidc_policy[count.index].json
  depends_on            = [aws_eks_cluster.ekscluster]
}

resource "aws_iam_role_policy_attachment" "sa_alb_policy_attach" {
  count      = var.create_service_accounts_role ? 1 : 0
  policy_arn = aws_iam_policy.alb_ingress_policy[count.index].arn
  role       = aws_iam_role.sa_alb_role[count.index].name
  depends_on = [aws_eks_cluster.ekscluster]
}

// Service Account External DNS

data "aws_iam_policy_document" "externaldns_role_oidc_policy" {
  count = var.create_service_accounts_role && var.manage_external_dns ? 1 : 0
  statement {
    sid     = "ekswebidentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = [format("arn:aws:iam::%s:oidc-provider/%s", data.aws_caller_identity.current.account_id, replace(aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer, "https://", ""))]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:default:external-dns"]
      variable = format("%s:sub", replace(aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer, "https://", ""))
    }
  }
}

data "aws_iam_policy_document" "external_dns_policy_doc" {
  count = var.create_service_accounts_role && var.manage_external_dns ? 1 : 0
  statement {
    sid    = "route53changerecord"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = formatlist("arn:aws:route53:::hostedzone/%s", var.external_dns_zone_ids)
  }
  statement {
    sid    = "route53listrecord"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns_policy" {
  count      = var.create_service_accounts_role && var.manage_external_dns ? 1 : 0
  policy     = data.aws_iam_policy_document.external_dns_policy_doc[count.index].json
  name       = format("%s-elb-external-dns-policy", aws_eks_cluster.ekscluster.name)
  depends_on = [aws_eks_cluster.ekscluster]
}
resource "aws_iam_role" "eks_external_dns_role" {
  count                 = var.create_service_accounts_role && var.manage_external_dns ? 1 : 0
  name                  = format("%s-sa-externaldns-role", aws_eks_cluster.ekscluster.name)
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.externaldns_role_oidc_policy[count.index].json
  depends_on            = [aws_eks_cluster.ekscluster]
}

resource "aws_iam_role_policy_attachment" "external_dns_policy_attach" {
  count      = var.create_service_accounts_role && var.manage_external_dns ? 1 : 0
  policy_arn = aws_iam_policy.external_dns_policy[count.index].arn
  role       = aws_iam_role.eks_external_dns_role[count.index].name
  depends_on = [aws_eks_cluster.ekscluster]
}

// karpenter

data "aws_iam_policy_document" "karpenter_role_oidc_policy" {
  count = var.create_service_accounts_role && var.manage_karpenter ? 1 : 0
  statement {
    sid     = "ekswebidentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = [format("arn:aws:iam::%s:oidc-provider/%s", data.aws_caller_identity.current.account_id, replace(aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer, "https://", ""))]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:karpenter:karpenter"]
      variable = format("%s:sub", replace(aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer, "https://", ""))
    }
  }
}

data "aws_iam_policy_document" "karpenter_policy_doc" {
  count = var.create_service_accounts_role && var.manage_karpenter ? 1 : 0
  statement {
    sid    = "karpenterautoscale"
    effect = "Allow"

    actions = [
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:RunInstances",
      "ec2:CreateTags",
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSpotPriceHistory",
      "ssm:GetParameter",
      "pricing:GetProducts"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "karpenterpassrole"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]
    resources = [aws_iam_role.worker_eks.arn]
  }
}

resource "aws_iam_policy" "karpenter_policy" {
  count      = var.create_service_accounts_role && var.manage_karpenter ? 1 : 0
  policy     = data.aws_iam_policy_document.karpenter_policy_doc[count.index].json
  name       = format("%s-karpenter-policy", aws_eks_cluster.ekscluster.name)
  depends_on = [aws_eks_cluster.ekscluster]
}
resource "aws_iam_role" "eks_karpenter_role" {
  count                 = var.create_service_accounts_role && var.manage_karpenter ? 1 : 0
  name                  = format("%s-sa-karpenter-role", aws_eks_cluster.ekscluster.name)
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.karpenter_role_oidc_policy[count.index].json
  depends_on            = [aws_eks_cluster.ekscluster]
}

resource "aws_iam_role_policy_attachment" "karpenter_policy_attach" {
  count      = var.create_service_accounts_role && var.manage_karpenter ? 1 : 0
  policy_arn = aws_iam_policy.karpenter_policy[count.index].arn
  role       = aws_iam_role.eks_karpenter_role[count.index].name
  depends_on = [aws_eks_cluster.ekscluster]
}

// Cluster Autoscaler
# Policy
data "aws_iam_policy_document" "cluster_autoscaler_role_oidc_policy" {
  count = var.create_service_accounts_role && var.manage_cluster_autoscaler ? 1 : 0
  statement {
    sid     = "ekswebidentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = [format("arn:aws:iam::%s:oidc-provider/%s", data.aws_caller_identity.current.account_id, replace(aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer, "https://", ""))]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
      variable = format("%s:sub", replace(aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer, "https://", ""))
    }
  }
}

data "aws_iam_policy_document" "kubernetes_cluster_autoscaler" {
  count = var.create_service_accounts_role && var.manage_cluster_autoscaler ? 1 : 0

  statement {
    sid = "clusterautoscale"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

}

resource "aws_iam_policy" "kubernetes_cluster_autoscaler" {
  count      = var.create_service_accounts_role && var.manage_cluster_autoscaler ? 1 : 0
  policy     = data.aws_iam_policy_document.kubernetes_cluster_autoscaler[count.index].json
  name       = format("%s-cluster_autoscaler-policy", aws_eks_cluster.ekscluster.name)
  depends_on = [aws_eks_cluster.ekscluster]
}

# Role

resource "aws_iam_role" "kubernetes_cluster_autoscaler" {
  count                 = var.create_service_accounts_role && var.manage_cluster_autoscaler ? 1 : 0
  name                  = format("%s-sa-cluster_autoscaler-role", aws_eks_cluster.ekscluster.name)
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.cluster_autoscaler_role_oidc_policy[count.index].json
  depends_on            = [aws_eks_cluster.ekscluster]
}

resource "aws_iam_role_policy_attachment" "kubernetes_cluster_autoscaler" {
  count      = var.create_service_accounts_role && var.manage_cluster_autoscaler ? 1 : 0
  policy_arn = aws_iam_policy.kubernetes_cluster_autoscaler[count.index].arn
  role       = aws_iam_role.kubernetes_cluster_autoscaler[count.index].name
  depends_on = [aws_eks_cluster.ekscluster]
}
