resource "aws_eks_cluster" "ekscluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.cluster_eks.arn
  version  = var.eks_version

  vpc_config {
    security_group_ids      = [aws_security_group.eks_sg.id]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
  ]
  tags = var.tags
}

// Managed node group
// Need to refer the latest_version


resource "aws_eks_node_group" "eks_node_spot_group" {
  count           = local.spot_count
  node_group_name = format("%s-spot-ng", var.eks_cluster_name)
  cluster_name    = aws_eks_cluster.ekscluster.name
  node_role_arn   = aws_iam_role.worker_eks.arn
  subnet_ids      = var.subnet_ids
  launch_template {
    id      = aws_launch_template.spot_instances_template[count.index].id
    version = var.spot_launch_template_version == null ? aws_launch_template.spot_instances_template[count.index].latest_version : var.spot_launch_template_version
  }
  dynamic "scaling_config" {
    for_each = var.spot_node_group_scaling_config
    content {
      desired_size = scaling_config.value.desired_size
      max_size     = scaling_config.value.max_size
      min_size     = scaling_config.value.min_size

    }
  }

  dynamic "update_config" {
    for_each = var.spot_node_update_config
    content {
      max_unavailable            = update_config.value.max_unavailable
      max_unavailable_percentage = update_config.value.max_unavailable_percentage

    }
  }

  dynamic "taint" {
    for_each = var.spot_node_group_taint
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
  ami_type      = "CUSTOM"
  capacity_type = "SPOT"
  disk_size     = null
  depends_on    = [aws_eks_cluster.ekscluster]
}
