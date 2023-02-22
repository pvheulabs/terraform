locals {
  device_docker     = "/dev/xvdb"
  spot_count        = var.enable_spot_instances ? 1 : 0
  alb_ingress_count = var.create_alb_policy ? 1 : 0
  tags              = var.create_eks_clusterautoscaler_policy ? merge(var.tags, { Name : var.eks_cluster_name, format("kubernetes.io/cluster/%s", var.eks_cluster_name) : "owned", workspace : terraform.workspace, Application : var.application_tag, format("k8s.io/cluster-autoscaler/%s", var.eks_cluster_name) : "owned", format("k8s.io/cluster-autoscaler/enabled") : "true" }) : merge(var.tags, { Name : var.eks_cluster_name, format("kubernetes.io/cluster/%s", var.eks_cluster_name) : "owned", workspace : terraform.workspace, Application : var.application_tag })
}
