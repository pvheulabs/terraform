output "eks_cluster_name" {
  description = "Name of eks cluster"
  value       = aws_eks_cluster.ekscluster.name
}

output "eks_worker_sg" {
  description = "EKS workers security group id"
  value       = aws_security_group.eks_worker_sg.id
}

output "eks_cluster_sg" {
  description = "EKS cluster security group id"
  value       = aws_security_group.eks_sg.id
}

output "eks_worker_iam_role" {
  description = "IAM Role for EKS Workers"
  value       = aws_iam_role.worker_eks.name
}

output "eks_cluster_oidc_issuer" {
  description = "Issuer URL for the OpenID Connect identity provider"
  value       = aws_eks_cluster.ekscluster.identity.0.oidc.0.issuer
}

output "eks_cluster_sa_alb_role" {
  description = "Service account Role for ALB Ingress"
  value       = compact(concat(aws_iam_role.sa_alb_role.*.arn, ["None"]))[0]
}

output "eks_cluster_sa_external_dns_role" {
  description = "Service account Role for External DNS"
  value       = compact(concat(aws_iam_role.eks_external_dns_role.*.arn, ["None"]))[0]
}

output "eks_cluster_endpoint" {
  description = "Eks Cluster Endpoint"
  value       = aws_eks_cluster.ekscluster.endpoint
}

output "eks_spot_node_group_arn" {
  description = "node group arn for spot"
  value       = compact(concat(aws_eks_node_group.eks_node_spot_group.*.arn, ["None"]))[0]
}
