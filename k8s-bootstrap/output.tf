output "alb_ingress_helm_release_version" {
  description = "helm release version for alb ingress controller"
  value       = compact(concat(helm_release.aws_alb_ingress_controller.*.version, ["None"]))[0]
}

output "karpenter_helm_release_version" {
  description = "helm release version for karpenter"
  value       = compact(concat(helm_release.karpenter.*.version, ["None"]))[0]
}

output "cluster_autoscaler_helm_release_version" {
  description = "helm release version for cluster autoscaler"
  value       = compact(concat(helm_release.cluster_autoscaler.*.version, ["None"]))[0]
}

output "reloader_helm_release_version" {
  description = "helm release version for reloader"
  value       = compact(concat(helm_release.reloader.*.version, ["None"]))[0]
}
