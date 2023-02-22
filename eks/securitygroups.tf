resource "aws_security_group" "eks_sg" {
  name        = format("%s-cluster-sg", var.eks_cluster_name)
  vpc_id      = var.vpc_id
  description = "Security Group for EKS Cluster"
  tags        = var.tags
}

resource "aws_security_group_rule" "eks_egress" {
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.eks_sg.*.id)
  type              = "egress"
}

resource "aws_security_group_rule" "eks_ingress_workers" {
  description              = "Allow the cluster to receive communication from the worker nodes"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = join("", aws_security_group.eks_sg.*.id)
  source_security_group_id = join("", aws_security_group.eks_worker_sg.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_ingress_cidr_blocks" {
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.eks_sg.*.id)
  type              = "ingress"
}

#Worker Nodes
resource "aws_security_group" "eks_worker_sg" {
  name        = format("%s-worker-sg", var.eks_cluster_name)
  description = "Security Group for EKS worker nodes"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "eks_worker_egress" {
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.eks_worker_sg.*.id)
  type              = "egress"
}

resource "aws_security_group_rule" "eks_worker_ingress_cluster" {
  description              = "All nodes to communicate each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = join("", aws_security_group.eks_worker_sg.*.id)
  source_security_group_id = join("", aws_security_group.eks_worker_sg.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_ingress_sg" {
  description              = "Allow worker kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = join("", aws_security_group.eks_worker_sg.*.id)
  source_security_group_id = join("", aws_security_group.eks_sg.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_node_https" {
  description       = "Allow inbound traffic from existing Security Groups"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.eks_worker_sg.*.id)
  type              = "ingress"
}

resource "aws_security_group_rule" "eks_node_ssh" {
  description       = "Allow inbound traffic from existing Security Groups"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.eks_worker_sg.*.id)
  type              = "ingress"
}
