module "test-kubernetes" {
  source                    = "./k8s-bootstrap"
  aws_account_id            = "000000000000"
  deployment_roles_name     = ["aws-eks-deployment-role"]
  dns_zone_name             = "example.cloud"
  eks_admin_users           = ["example@pvh.com"]
  eks_cluster_name          = "example-cluster"
  k8s_application_namespace = ["application"]
  sso_admin_roles_name      = ["sso-admin"]
  vpc_id                    = "vpc-1231231231231"
  create_aws_auth           = true
  create_external_dns       = true
  create_ingress_controller = true
  create_fluent-bit         = true
  create_karpenter          = true
  create_cluster_autoscaler = false
  create_reloader           = true
  cluster_endpoint          = data.remote_state.abc.outputs.cluster_endpoint
}

