locals {
  external_dns_name             = var.external_dns_name
  ingress_serviceaccount_name   = var.ingress_serviceaccount_name
  create_external_dns           = var.create_external_dns ? 1 : 0
  create_fluent-bit             = var.create_fluent-bit ? 1 : 0
  create_ingress_controller     = var.create_ingress_controller ? 1 : 0
  create_karpenter              = var.create_karpenter ? 1 : 0
  create_cluster_autoscaler     = var.create_cluster_autoscaler ? 1 : 0
  create_reloader               = var.create_reloader ? 1 : 0
  reloader_name                 = "reloader"
  reloader_chart_name           = "reloader"
  cluster_autoscaler_name       = "cluster-autoscaler"
  cluster_autoscaler_chart_name = "cluster-autoscaler"
  karpenter_name                = "karpenter"
  karpenter_namespace           = "karpenter"
  karpenter_chart_name          = "karpenter"
  create_karpenter_namespace    = true
  create_aws_auth               = var.create_aws_auth ? 1 : 0
}
