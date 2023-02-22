variable "aws_account_id" {
  description = "aws account id where the eks cluster is deployed"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the eks cluster"
  type        = string
}

variable "sso_admin_roles_name" {
  description = "list of admin sso role name for mapping aws auth"
  type        = list(string)
  default     = []
}

variable "deployment_roles_name" {
  description = "list of eks deployment role name for mapping aws auth"
  type        = list(string)
  default     = []
}

variable "dns_zone_name" {
  description = "dns zone name which needs to be managed by external-dns"
  type        = string
  default     = null
}

variable "external_dns_image" {
  description = "External DNS image for deployment"
  type        = string
  default     = "eu.gcr.io/k8s-artifacts-prod/external-dns/external-dns"
}

variable "external_dns_image_tag" {
  description = "container version image for external-dns service. Refer https://github.com/kubernetes-sigs/external-dns/tags"
  type        = string
  default     = "v0.10.2"
}

variable "external_dns_aws_zone_type" {
  description = "aws zone type for external dns"
  type        = string
  default     = "public"
}

variable "k8s_application_namespace" {
  description = "name of application to create namespace"
  type        = list(string)
}

variable "eks_admin_users" {
  description = "List of users which will have admin role"
  type        = list(string)
  default     = []
}


variable "alb_ingress_helm_chart_version" {
  description = "helm version for alb ingress"
  type        = string
  default     = "1.4.3"
}

variable "alb_ingress_image_tag" {
  description = "alb ingress controller image tag"
  type        = string
  default     = "v2.4.1"
}

variable "alb_ingress_helm_chart_repository" {
  description = "Name of helm repository for alb ingress controller"
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "create_external_dns" {
  description = "deploy external-dns deployment to manage route53 domain record. Only applicable if you own the zone in your aws account."
  type        = bool
  default     = false
}

variable "create_ingress_controller" {
  description = "deploy ingress controller deployment to manage alb/nlb loadbalancer."
  type        = bool
  default     = false
}

variable "helm_namespaces" {
  description = "namespace where helm charts will be deployed"
  type        = map(string)
  default = {
    external-dns = "default"
    alb-ingress  = "kube-system"
  }
}

variable "create_fluent-bit" {
  description = "deploy fluent-bit deployment to manage application logs. Only applicable if you own the zone in your aws account."
  type        = bool
  default     = false
}

variable "fluent-bit_namespace" {
  description = "namespace for fluent-bit where fluentd will be deployed"
  type        = string
  default     = "amazon-cloudwatch"
}

variable "fluent-bit_image_tag" {
  description = "fluent-bit image version will be deployed"
  type        = string
  default     = "2.28.0"
}

variable "fluent-bit_image" {
  description = "fluent-bit image repository path"
  type        = string
  default     = "amazon/aws-for-fluent-bit"
}

variable "fluent-bit_limit_cpu" {
  description = "fluent-bit pod cpu limit"
  type        = string
  default     = "200m"
}

variable "fluent-bit_limit_memory" {
  description = "fluent-bit pod memory limit"
  type        = string
  default     = "500Mi"
}

variable "fluent-bit_request_cpu" {
  description = "fluent-bit pod cpu request"
  type        = string
  default     = "100m"
}

variable "fluent-bit_request_memory" {
  description = "fluent-bit pod memory request"
  type        = string
  default     = "200Mi"
}

variable "vpc_id" {
  description = "vpc id of eks cluster"
  type        = string
}

variable "http_server" {
  description = "http server for fluent bit server"
  default     = "On"
  type        = string
}

variable "http_port" {
  description = "http server port for fluent bit server"
  default     = "2020"
  type        = string
}

variable "read_from_head" {
  description = "log file read from head"
  default     = "Off"
  type        = string
}

variable "read_from_tail" {
  description = "log file read from tail"
  default     = "On"
  type        = string
}

variable "ci_version" {
  description = "k8s CI version for fluent-bit"
  type        = string
  default     = "k8s/1.3.9"
}

variable "external_dns_name" {
  default     = "external-dns"
  description = "external dns name"
  type        = string
}

variable "ingress_serviceaccount_name" {
  default     = "aws-load-balancer-controller"
  description = "ingress controller name"
  type        = string
}
variable "create_karpenter" {
  description = "Allow Karpenter automatically provisions new nodes in response to unschedulable pods. Only applicable if you want to manage Cluster Scaling with karpenter."
  type        = bool
  default     = false
}
variable "cluster_endpoint" {
  description = "Eks Cluster Api Endpoint.Only required if you use karpenter."
  type        = string
  default     = null
}
variable "create_cluster_autoscaler" {
  description = "Allow Cluster Autoscaler automatically provisions new nodes in response to unschedulable pods. Only applicable if you want to manage Cluster Scaling with Cluster Autoscaler."
  type        = bool
  default     = false
}
variable "create_reloader" {
  description = "Reloader can watch changes in ConfigMap and Secret and do rolling upgrades on Pods with their associated DeploymentConfigs, Deployments, Daemonset Statefulset and Rollouts."
  type        = bool
  default     = false
}
variable "cluster_autoscaler_helm_repository" {
  description = "Cluster Autoscaler Helm Repository URL"
  default     = "https://kubernetes.github.io/autoscaler"
  type        = string
}
variable "cluster_autoscaler_helm_chart_version" {
  description = "Cluster Autoscaler Helm chart Version"
  type        = string
  default     = "9.21.0"
}
variable "reloader_helm_repository" {
  description = "Reloader Helm Repository Chart URL"
  type        = string
  default     = "https://stakater.github.io/stakater-charts"
}
variable "reloader_helm_chart_version" {
  description = "Reloader Helm Chart Version"
  type        = string
  default     = "v0.0.118"
}
variable "karpenter_helm_repository" {
  description = "karpenter Helm Repository Chart URL"
  type        = string
  default     = "https://charts.karpenter.sh"
}
variable "karpenter_helm_chart_version" {
  description = "karpenter Helm Chart Version"
  type        = string
  default     = "v0.16.0"
}
variable "create_aws_auth" {
  description = "Allow aws auth configure for role and users"
  type        = bool
  default     = false
}