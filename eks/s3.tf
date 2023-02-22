resource "aws_s3_bucket" "logging_bucket" {
  count         = local.alb_ingress_count
  bucket        = var.alb_log_bucket_name != null ? format("%s-alb-log-bucket", var.alb_log_bucket_name) : format("%s-alb-log-bucket", terraform.workspace)
  force_destroy = var.force_destroy
  tags          = var.tags

}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  count  = local.alb_ingress_count
  bucket = aws_s3_bucket.logging_bucket[count.index].id
  policy = data.aws_iam_policy_document.alb_s3_bucket_policy[count.index].json
}

resource "aws_s3_bucket_lifecycle_configuration" "logging_bucket_configuration" {
  count  = local.alb_ingress_count
  bucket = aws_s3_bucket.logging_bucket[count.index].id
  rule {
    id     = format("%s-s3-lifecycle", var.eks_cluster_name)
    status = var.s3_lifecycle_rule_enabled
    transition {
      storage_class = "STANDARD_IA"
      days          = var.s3_transition_standard_ia_days
    }
    transition {
      storage_class = "GLACIER"
      days          = var.s3_transition_glacier_days
    }
    noncurrent_version_expiration {
      noncurrent_days = var.s3_noncurrent_version_expiration_days
    }

    noncurrent_version_transition {
      noncurrent_days = var.s3_noncurrent_version_transition_glacier_days
      storage_class   = "GLACIER"
    }
    expiration {
      days = var.s3_expiration_days
    }
  }
}



resource "aws_ssm_parameter" "eks_alb_log_bucket" {
  count       = local.alb_ingress_count
  name        = var.alb_log_bucket_name != null ? format("/eks/%s/alb/logging_bucket", var.alb_log_bucket_name) : format("/eks/%s/alb/logging_bucket", terraform.workspace)
  description = "ALB Log bucket"
  type        = "String"
  value       = compact(concat(aws_s3_bucket.logging_bucket.*.bucket, ["None"]))[0]
  tags        = var.tags
}
