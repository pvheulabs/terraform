# kubernetes-bootstrap 

#### This module supports below deployment/services 
```text
- AWS authconfig
- External DNS
- AWS Ingress Controller
- Karpenter
- Cluster Autoscaler
- Reloader
- Fluentbit
```


#### Notes: Please read this before deploying the code

```text
1. This module uses kubernetes and helm provider, so its advisable to have this deployed into new terraform workspace on pvh-terraform-other-provider-state bucket.
2. If you are using karpenter, the namespace karpenter is created as part of helm chart. Also ensure you have the cluster_endpoint variable set.
3. To use Karpenter and Cluster Autoscaler feature, your should be using https://gitlab.tools.eu.pvh.cloud/terraform/aws-modules/eks starting from v1.0.1
4. To use fluentbit into eks fargate add k8s-app = "fluent-bit" as label.
5. Refer the example folder for sample pipeline..
6. Its recommended to use latest eks terraform module https://gitlab.tools.eu.pvh.cloud/terraform/aws-modules/eks 
```

## How to Use:
```hcl-terraform
module "test-kubernetes" {
  source                    = "./terraform/k8s-bootstrap"
  aws_account_id            = "000000000000"
  deployment_roles_name     = ["aws-eks-deployment-role"]
  dns_zone_name             = "example.eu.pvh.cloud"
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
```
## Sample of provider block  - Need to be added to application code(not present in the module)
```hcl
provider "kubernetes" {
  config_path = var.config_path
  token       = var.eks_token
}

provider "helm" {
  kubernetes {
    config_path = var.config_path
    token       = var.eks_token
  }
}
```
## Sample of terraform cli CI/CD
```shell
export EKS_TOKEN=$(cat .kube/token)
terraform apply  -var eks_token=$EKS_TOKEN -var "config_path=.kube/config"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0, <= 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0, <= 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0, <= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0, <= 4.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0, <= 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0, <= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.aws_alb_ingress_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.reloader](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.fluent-bit](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.fluent-bit](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_daemonset.fluent-bit](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemonset) | resource |
| [kubernetes_deployment.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_manifest.fluent-bit-cluster-info](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.fluent-bit_configmaps](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.fluent-bit_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.fluent-bit](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_ingress_helm_chart_repository"></a> [alb\_ingress\_helm\_chart\_repository](#input\_alb\_ingress\_helm\_chart\_repository) | Name of helm repository for alb ingress controller | `string` | `"https://aws.github.io/eks-charts"` | no |
| <a name="input_alb_ingress_helm_chart_version"></a> [alb\_ingress\_helm\_chart\_version](#input\_alb\_ingress\_helm\_chart\_version) | helm version for alb ingress | `string` | `"1.4.1"` | no |
| <a name="input_alb_ingress_image_tag"></a> [alb\_ingress\_image\_tag](#input\_alb\_ingress\_image\_tag) | alb ingress controller image tag | `string` | `"v2.4.1"` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | aws account id where the eks cluster is deployed | `string` | n/a | yes |
| <a name="input_ci_version"></a> [ci\_version](#input\_ci\_version) | k8s CI version for fluent-bit | `string` | `"k8s/1.3.9"` | no |
| <a name="input_cluster_autoscaler_helm_chart_version"></a> [cluster\_autoscaler\_helm\_chart\_version](#input\_cluster\_autoscaler\_helm\_chart\_version) | Cluster Autoscaler Helm chart Version | `string` | `"9.19.1"` | no |
| <a name="input_cluster_autoscaler_helm_repository"></a> [cluster\_autoscaler\_helm\_repository](#input\_cluster\_autoscaler\_helm\_repository) | Cluster Autoscaler Helm Repository URL | `string` | `"https://kubernetes.github.io/autoscaler"` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Eks Cluster Api Endpoint.Only required if you use karpenter. | `string` | `null` | no |
| <a name="input_create_aws_auth"></a> [create\_aws\_auth](#input\_create\_aws\_auth) | Allow aws auth configure for role and users | `bool` | `false` | no |
| <a name="input_create_cluster_autoscaler"></a> [create\_cluster\_autoscaler](#input\_create\_cluster\_autoscaler) | Allow Cluster Autoscaler automatically provisions new nodes in response to unschedulable pods. Only applicable if you want to manage Cluster Scaling with Cluster Autoscaler. | `bool` | `false` | no |
| <a name="input_create_external_dns"></a> [create\_external\_dns](#input\_create\_external\_dns) | deploy external-dns deployment to manage route53 domain record. Only applicable if you own the zone in your aws account. | `bool` | `false` | no |
| <a name="input_create_fluent-bit"></a> [create\_fluent-bit](#input\_create\_fluent-bit) | deploy fluent-bit deployment to manage application logs. Only applicable if you own the zone in your aws account. | `bool` | `false` | no |
| <a name="input_create_ingress_controller"></a> [create\_ingress\_controller](#input\_create\_ingress\_controller) | deploy ingress controller deployment to manage alb/nlb loadbalancer. | `bool` | `false` | no |
| <a name="input_create_karpenter"></a> [create\_karpenter](#input\_create\_karpenter) | Allow Karpenter automatically provisions new nodes in response to unschedulable pods. Only applicable if you want to manage Cluster Scaling with karpenter. | `bool` | `false` | no |
| <a name="input_create_reloader"></a> [create\_reloader](#input\_create\_reloader) | Reloader can watch changes in ConfigMap and Secret and do rolling upgrades on Pods with their associated DeploymentConfigs, Deployments, Daemonset Statefulset and Rollouts. | `bool` | `false` | no |
| <a name="input_deployment_roles_name"></a> [deployment\_roles\_name](#input\_deployment\_roles\_name) | list of eks deployment role name for mapping aws auth | `list(string)` | `[]` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | dns zone name which needs to be managed by external-dns | `string` | `null` | no |
| <a name="input_eks_admin_users"></a> [eks\_admin\_users](#input\_eks\_admin\_users) | List of users which will have admin role | `list(string)` | `[]` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the eks cluster | `string` | n/a | yes |
| <a name="input_external_dns_aws_zone_type"></a> [external\_dns\_aws\_zone\_type](#input\_external\_dns\_aws\_zone\_type) | aws zone type for external dns | `string` | `"public"` | no |
| <a name="input_external_dns_image"></a> [external\_dns\_image](#input\_external\_dns\_image) | External DNS image for deployment | `string` | `"eu.gcr.io/k8s-artifacts-prod/external-dns/external-dns"` | no |
| <a name="input_external_dns_image_tag"></a> [external\_dns\_image\_tag](#input\_external\_dns\_image\_tag) | container version image for external-dns service. Refer https://github.com/kubernetes-sigs/external-dns/tags | `string` | `"v0.10.2"` | no |
| <a name="input_external_dns_name"></a> [external\_dns\_name](#input\_external\_dns\_name) | external dns name | `string` | `"external-dns"` | no |
| <a name="input_fluent-bit_image"></a> [fluent-bit\_image](#input\_fluent-bit\_image) | fluent-bit image repository path | `string` | `"amazon/aws-for-fluent-bit"` | no |
| <a name="input_fluent-bit_image_tag"></a> [fluent-bit\_image\_tag](#input\_fluent-bit\_image\_tag) | fluent-bit image version will be deployed | `string` | `"2.10.0"` | no |
| <a name="input_fluent-bit_limit_cpu"></a> [fluent-bit\_limit\_cpu](#input\_fluent-bit\_limit\_cpu) | fluent-bit pod cpu limit | `string` | `"200m"` | no |
| <a name="input_fluent-bit_limit_memory"></a> [fluent-bit\_limit\_memory](#input\_fluent-bit\_limit\_memory) | fluent-bit pod memory limit | `string` | `"500Mi"` | no |
| <a name="input_fluent-bit_namespace"></a> [fluent-bit\_namespace](#input\_fluent-bit\_namespace) | namespace for fluent-bit where fluentd will be deployed | `string` | `"amazon-cloudwatch"` | no |
| <a name="input_fluent-bit_request_cpu"></a> [fluent-bit\_request\_cpu](#input\_fluent-bit\_request\_cpu) | fluent-bit pod cpu request | `string` | `"100m"` | no |
| <a name="input_fluent-bit_request_memory"></a> [fluent-bit\_request\_memory](#input\_fluent-bit\_request\_memory) | fluent-bit pod memory request | `string` | `"200Mi"` | no |
| <a name="input_helm_namespaces"></a> [helm\_namespaces](#input\_helm\_namespaces) | namespace where helm charts will be deployed | `map(string)` | <pre>{<br>  "alb-ingress": "kube-system",<br>  "external-dns": "default"<br>}</pre> | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | http server port for fluent bit server | `string` | `"2020"` | no |
| <a name="input_http_server"></a> [http\_server](#input\_http\_server) | http server for fluent bit server | `string` | `"On"` | no |
| <a name="input_ingress_serviceaccount_name"></a> [ingress\_serviceaccount\_name](#input\_ingress\_serviceaccount\_name) | ingress controller name | `string` | `"aws-load-balancer-controller"` | no |
| <a name="input_k8s_application_namespace"></a> [k8s\_application\_namespace](#input\_k8s\_application\_namespace) | name of application to create namespace | `list(string)` | n/a | yes |
| <a name="input_karpenter_helm_chart_version"></a> [karpenter\_helm\_chart\_version](#input\_karpenter\_helm\_chart\_version) | karpenter Helm Chart Version | `string` | `"v0.5.3"` | no |
| <a name="input_karpenter_helm_repository"></a> [karpenter\_helm\_repository](#input\_karpenter\_helm\_repository) | karpenter Helm Repository Chart URL | `string` | `"https://charts.karpenter.sh"` | no |
| <a name="input_read_from_head"></a> [read\_from\_head](#input\_read\_from\_head) | log file read from head | `string` | `"Off"` | no |
| <a name="input_read_from_tail"></a> [read\_from\_tail](#input\_read\_from\_tail) | log file read from tail | `string` | `"On"` | no |
| <a name="input_reloader_helm_chart_version"></a> [reloader\_helm\_chart\_version](#input\_reloader\_helm\_chart\_version) | Reloader Helm Chart Version | `string` | `"v0.0.110"` | no |
| <a name="input_reloader_helm_repository"></a> [reloader\_helm\_repository](#input\_reloader\_helm\_repository) | Reloader Helm Repository Chart URL | `string` | `"https://stakater.github.io/stakater-charts"` | no |
| <a name="input_sso_admin_roles_name"></a> [sso\_admin\_roles\_name](#input\_sso\_admin\_roles\_name) | list of admin sso role name for mapping aws auth | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id of eks cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_ingress_helm_release_version"></a> [alb\_ingress\_helm\_release\_version](#output\_alb\_ingress\_helm\_release\_version) | helm release version for alb ingress controller |
| <a name="output_cluster_autoscaler_helm_release_version"></a> [cluster\_autoscaler\_helm\_release\_version](#output\_cluster\_autoscaler\_helm\_release\_version) | helm release version for cluster autoscaler |
| <a name="output_karpenter_helm_release_version"></a> [karpenter\_helm\_release\_version](#output\_karpenter\_helm\_release\_version) | helm release version for karpenter |
| <a name="output_reloader_helm_release_version"></a> [reloader\_helm\_release\_version](#output\_reloader\_helm\_release\_version) | helm release version for reloader |
