data "aws_caller_identity" "current" {}

data "aws_ami" "eks_worker" {
  owners      = [var.ami_owner_id]
  most_recent = true
  name_regex  = var.eks_image_regex
}
