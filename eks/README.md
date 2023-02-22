# eks

### How to Use:

```hcl-terraform
module "test_eks" {
  source                       = "./terraform/eks"
  vpc_id                       = module.vpc.vpc_id
  subnet_ids                   = module.vpc.private_subnets
  alb_log_bucket_name          = format("%s-test-alb", terraform.workspace)
  eks_cluster_name             = format("test-%s", terraform.workspace)
  eks_version                  = "1.21"
  allowed_cidr_blocks          = concat(["10.0.0.0/8"], ["10.34.122.0/23"])
  autoscale_desired_size       = 1
  autoscale_maxsize            = 2
  autoscale_minsize            = 1
  cloudwatch_agent_config_type = "advanced"
  eks_container_runtime        = "containerd"
  workers_instance_type        = "t3.micro"
  worker_key                   = "test"
  create_service_accounts_role = true
  manage_external_dns          = false
  external_dns_zone_ids        = []
  tags                         = merge(var.tags, tomap({ "Environment": terraform.workspace }))
}
```

### with Instances Refresh

```hcl-terraform
module "test_eks" {
  source                       = "./terraform/eks"
  vpdc_id                       = module.vpc.vpc_id
  subnet_ids                   = module.vpc.private_subnets
  alb_log_bucket_name          = format("%s-test-alb", terraform.workspace)
  eks_cluster_name             = format("test-%s", terraform.workspace)
  eks_version                  = "1.21"
  allowed_cidr_blocks          = concat(["10.0.0.0/8"], ["10.34.122.0/23"])
  autoscale_desired_size       = 1
  autoscale_maxsize            = 2
  autoscale_minsize            = 1
  cloudwatch_agent_config_type = "advanced"
  eks_container_runtime        = "containerd"
  workers_instance_type        = "t3.micro"
  worker_key                   = "test"
  create_service_accounts_role = true
  enable_instance_refresh      = true
  manage_external_dns          = false
  external_dns_zone_ids        = []
  tags                         = merge(var.tags, tomap({ "Environment": terraform.workspace }))
}
```

### Spot Instances
#### Notes:

```text
- Refer the official docs on managed node group - https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html
- Refer How spot instances works in node group - https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html#Spot
- There are certain limitations on managed node groups.
    - Spot instances by default will only have "capacity Optimized" as allocation strategy.
    - Spot price can't be set. The default max price is on-demand price of the instances.
    - By default, node group will be updated if spot_launch_template_version is not set.
- Spot instances launched by node groups will have additional 2 labels. Ensure you schedule the pods matching these labels for spot specific workloads.
        - eks.amazonaws.com/nodegroup=<spot-node-group-name>
        - eks.amazonaws.com/capacityType=SPOT

```

##### Sample node labels for SPOT

```shell
kubectl get nodes --show-labels -o wide
NAME                                             STATUS   ROLES    AGE     VERSION               INTERNAL-IP     EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                 CONTAINER-RUNTIME    LABELS
ip-10-34-123-121.eu-central-1.compute.internal   Ready    <none>   8m54s   v1.23.9-eks-ba74326   10.34.123.121   <none>        Amazon Linux 2   5.4.209-116.367.amzn2.x86_64   containerd://1.6.6   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t3.micro,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=eu-central-1,failure-domain.beta.kubernetes.io/zone=eu-central-1b,k8s.io/cloud-provider-aws=7be50cdcabf68dadf3784d0cc5421a32,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip-10-34-123-121.eu-central-1.compute.internal,kubernetes.io/os=linux,node.kubernetes.io/instance-type=t3.micro,topology.kubernetes.io/region=eu-central-1,topology.kubernetes.io/zone=eu-central-1b
ip-10-34-123-66.eu-central-1.compute.internal    Ready    <none>   5m52s   v1.23.9-eks-ba74326   10.34.123.66    <none>        Amazon Linux 2   5.4.209-116.367.amzn2.x86_64   containerd://1.6.6   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t3.micro,beta.kubernetes.io/os=linux,eks.amazonaws.com/capacityType=SPOT,eks.amazonaws.com/nodegroup-image=ami-0bfa6e2933197a35e,eks.amazonaws.com/nodegroup=spot-eu-tools-dev-rbalak-spot-ng,eks.amazonaws.com/sourceLaunchTemplateId=lt-023b9030431175436,eks.amazonaws.com/sourceLaunchTemplateVersion=1,failure-domain.beta.kubernetes.io/region=eu-central-1,failure-domain.beta.kubernetes.io/zone=eu-central-1b,k8s.io/cloud-provider-aws=7be50cdcabf68dadf3784d0cc5421a32,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip-10-34-123-66.eu-central-1.compute.internal,kubernetes.io/os=linux,node.kubernetes.io/instance-type=t3.micro,topology.kubernetes.io/region=eu-central-1,topology.kubernetes.io/zone=eu-central-1b
```


```hcl-terraform

module "spot_eks" {
  source                       = "./terraform/eks"
  enable_spot_instances        = true
  vpc_id                       = module.vpc.vpc_id
  subnet_ids                   = module.vpc.vpc_id.private_subnet
  alb_log_bucket_name          = format("%s-spot-alb", terraform.workspace)
  eks_cluster_name             = format("spot-%s", terraform.workspace)
  eks_version                  = "1.23"
  allowed_cidr_blocks          = concat(["10.0.0.0/8"], ["10.34.122.0/23"])
  autoscale_desired_size       = 1
  autoscale_maxsize            = 2
  autoscale_minsize            = 1
  spot_node_group_scaling_config = [{
    desired_size = 1
    max_size     = 2
    min_size     = 1

  }]
  cloudwatch_agent_config_type = "advanced"
  workers_instance_type        = "t3.micro"
  worker_key                   = "cloudops-dev"
  create_service_accounts_role = true
  manage_external_dns          = false
  external_dns_zone_ids        = []
  tags                         = merge(var.tags, tomap({ "Environment" = terraform.workspace }), tomap({ Application = "spot" }))
}

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.75.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.75.0, < 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.worker_ag_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.instance_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization_low](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_low](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.worker_node_cpu_utilization_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.worker_node_disk_usage_high_xvda1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.worker_node_disk_usage_high_xvdb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.worker_node_memory_usage_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_eks_cluster.ekscluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.eks_node_spot_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_instance_profile.eks-worker-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.eks_openid_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.alb_ingress_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.external_dns_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.karpenter_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.kubernetes_cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cluster_eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_external_dns_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_karpenter_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.kubernetes_cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sa_alb_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.worker_eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ec2_cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_ec2_container_registry_read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_ingress_alb_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_worker_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_worker_node_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.external_dns_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.karpenter_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.kubernetes_cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sa_alb_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.instances_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_launch_template.spot_instances_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_s3_bucket.logging_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.logging_bucket_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.logging_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_security_group.eks_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.eks_worker_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.eks_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_ingress_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_ingress_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_node_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_node_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_worker_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_worker_ingress_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_worker_ingress_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.eks_alb_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.elb_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.alb_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.alb_s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_autoscaler_role_oidc_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eks_role_oidc_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.external_dns_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.externaldns_role_oidc_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.karpenter_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.karpenter_role_oidc_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kubernetes_cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.worker_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_instances.eks_worker_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_user_data"></a> [additional\_user\_data](#input\_additional\_user\_data) | Addtional user data that will be executed after the instance joins the cluster. Defaults to echo no additional user data provided. | `string` | `"echo 'no additional user data provided'"` | no |
| <a name="input_alarm_cpu_high"></a> [alarm\_cpu\_high](#input\_alarm\_cpu\_high) | (Optional) The high CPU  threshold percentage. | `number` | `20` | no |
| <a name="input_alarm_cpu_low"></a> [alarm\_cpu\_low](#input\_alarm\_cpu\_low) | (Optional) The Low CPU threshold percentage. | `number` | `20` | no |
| <a name="input_alarm_memory_high"></a> [alarm\_memory\_high](#input\_alarm\_memory\_high) | (Optional) The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds, but should not be used for alarms based on anomaly detection models. Value to high Memory threshold. | `number` | `80` | no |
| <a name="input_alarm_memory_low"></a> [alarm\_memory\_low](#input\_alarm\_memory\_low) | (Optional) The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds, but should not be used for alarms based on anomaly detection models.Value to low Memory threshold. | `number` | `40` | no |
| <a name="input_alb_log_bucket_name"></a> [alb\_log\_bucket\_name](#input\_alb\_log\_bucket\_name) | (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. | `string` | `null` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks to be allowed to connect to the EKS cluster. | `list(string)` | `[]` | no |
| <a name="input_ami_owner_id"></a> [ami\_owner\_id](#input\_ami\_owner\_id) | (Required) List of AMI owners to limit search. At least 1 value must be specified. Valid values: an AWS account ID, self (the current account), or an AWS owner alias (e.g. amazon, aws-marketplace, microsoft). | `string` | n/a | yes |
| <a name="input_application_tag"></a> [application\_tag](#input\_application\_tag) | A list of tag blocks for autoscaling group. | `string` | `"EKS"` | no |
| <a name="input_asg_termination_policies"></a> [asg\_termination\_policies](#input\_asg\_termination\_policies) | (Optional) A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default. | `list(string)` | <pre>[<br>  "OldestInstance"<br>]</pre> | no |
| <a name="input_autoscale_desired_size"></a> [autoscale\_desired\_size](#input\_autoscale\_desired\_size) | desired capacity size of the auto scale group. | `number` | `1` | no |
| <a name="input_autoscale_maxsize"></a> [autoscale\_maxsize](#input\_autoscale\_maxsize) | The maximum size of the auto scale group. | `number` | `2` | no |
| <a name="input_autoscale_minsize"></a> [autoscale\_minsize](#input\_autoscale\_minsize) | The minimum size of the auto scale group. | `number` | `1` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Block devices attached to worker nodes. By default root volume will be 20G and other volume will be 100G will be attached to instances. device names are valid only for PVH-ISG-Amazon-Linux-EKS image. | `list(any)` | <pre>[<br>  {<br>    "device_name": "/dev/xvda",<br>    "ebs": {<br>      "delete_on_termination": true,<br>      "volume_size": 20,<br>      "volume_type": "gp3"<br>    }<br>  },<br>  {<br>    "device_name": "/dev/xvdb",<br>    "ebs": {<br>      "delete_on_termination": true,<br>      "volume_size": 100,<br>      "volume_type": "gp3"<br>    }<br>  }<br>]</pre> | no |
| <a name="input_cloudwatch_agent_config_type"></a> [cloudwatch\_agent\_config\_type](#input\_cloudwatch\_agent\_config\_type) | Type of cloudwatch wizard required. Allowed values: standard, advanced. | `string` | `"standard"` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | (Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. | `number` | `7` | no |
| <a name="input_cpu_resources"></a> [cpu\_resources](#input\_cpu\_resources) | Specifies that per-cpu metrics are to be collected. The only allowed value is *. If you include this field and value, per-cpu metrics are collected. | `string` | `"\"resources\": [\"*\"],"` | no |
| <a name="input_create_alb_policy"></a> [create\_alb\_policy](#input\_create\_alb\_policy) | Attach additional policy for alb ingress. | `bool` | `true` | no |
| <a name="input_create_eks_clusterautoscaler_policy"></a> [create\_eks\_clusterautoscaler\_policy](#input\_create\_eks\_clusterautoscaler\_policy) | Attach additional policy for EKS cluster autoscaler. | `bool` | `true` | no |
| <a name="input_create_service_accounts_role"></a> [create\_service\_accounts\_role](#input\_create\_service\_accounts\_role) | (Optional) create services accounts for alb-ingress and external dns | `bool` | `false` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | eks cluster name. | `string` | n/a | yes |
| <a name="input_eks_container_runtime"></a> [eks\_container\_runtime](#input\_eks\_container\_runtime) | Specify a container runtime. Allowed values:: 'dockerd', 'containerd' | `string` | `"containerd"` | no |
| <a name="input_eks_image_regex"></a> [eks\_image\_regex](#input\_eks\_image\_regex) | (Optional) A regex string to apply to the AMI list returned by AWS. | `string` | n/a | yes |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | The Kubernetes server version for the cluster. If you do not specify a value, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS. The value must be configured and increased to upgrade the version when desired. Downgrades are not supported by EKS. | `string` | `"1.23"` | no |
| <a name="input_enable_cloudwatch_agent_cpu_per_core_metrics"></a> [enable\_cloudwatch\_agent\_cpu\_per\_core\_metrics](#input\_enable\_cloudwatch\_agent\_cpu\_per\_core\_metrics) | Enable to monitor cpu usage per core level, it involves additional cost. | `bool` | `false` | no |
| <a name="input_enable_cloudwatch_agent_install"></a> [enable\_cloudwatch\_agent\_install](#input\_enable\_cloudwatch\_agent\_install) | Enable this variable to install cloudwatch agent on worker nodes. | `bool` | `true` | no |
| <a name="input_enable_cloudwatch_alarms_per_worker_node"></a> [enable\_cloudwatch\_alarms\_per\_worker\_node](#input\_enable\_cloudwatch\_alarms\_per\_worker\_node) | Enable CloudWatch Alarms for each worker node. Using Terraform 13 is recommended, please read the Notes. cloudwatch\_agent\_config\_type needs to be `advanced`. Metrics are `CPUUtilization`, `mem_used_percent` and `disk_used_percent` for `/` and `/var/lib/docker`. | `bool` | `false` | no |
| <a name="input_enable_detailed_monitoring"></a> [enable\_detailed\_monitoring](#input\_enable\_detailed\_monitoring) | Enable this to have launched EC2 instance will have detailed monitoring enabled. | `bool` | `false` | no |
| <a name="input_enable_instance_refresh"></a> [enable\_instance\_refresh](#input\_enable\_instance\_refresh) | Enable Instance refresh for autoscaling group | `bool` | `false` | no |
| <a name="input_enable_spot_instances"></a> [enable\_spot\_instances](#input\_enable\_spot\_instances) | set to true if you need spot instances in the launch configuration. Default to false | `bool` | `false` | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. | `bool` | `false` | no |
| <a name="input_external_dns_zone_ids"></a> [external\_dns\_zone\_ids](#input\_external\_dns\_zone\_ids) | List of ZoneID's that can be managed by external dns service account | `list(string)` | `[]` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Optional A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `true` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | (Optional, Default: 300) Time (in seconds) after instance comes into service before checking health. | `number` | `300` | no |
| <a name="input_instance_log_group"></a> [instance\_log\_group](#input\_instance\_log\_group) | (Optional, Forces new resource) The name of the log group. If omitted, Terraform will assign a random, unique name. | `string` | `null` | no |
| <a name="input_instance_refresh"></a> [instance\_refresh](#input\_instance\_refresh) | (Optional) If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated. Refer https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#instance_refresh | <pre>list(object({<br>    strategy = string<br>    preferences = object({<br>      checkpoint_delay       = number<br>      checkpoint_percentages = list(number)<br>      instance_warmup        = number<br>      min_healthy_percentage = number<br><br>    })<br>    triggers = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "preferences": {<br>      "checkpoint_delay": null,<br>      "checkpoint_percentages": null,<br>      "instance_warmup": null,<br>      "min_healthy_percentage": 50<br>    },<br>    "strategy": "Rolling",<br>    "triggers": [<br>      "launch_configuration"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Template version. Can be version number, $Latest, or $Default. | `string` | `"$Latest"` | no |
| <a name="input_manage_cluster_autoscaler"></a> [manage\_cluster\_autoscaler](#input\_manage\_cluster\_autoscaler) | Manage the Cluster Scaling with Cluster Autoscaler service in k8s | `bool` | `false` | no |
| <a name="input_manage_external_dns"></a> [manage\_external\_dns](#input\_manage\_external\_dns) | Manage the zone via external dns service in k8s | `bool` | `false` | no |
| <a name="input_manage_karpenter"></a> [manage\_karpenter](#input\_manage\_karpenter) | Manage the Cluster Scaling with karpenter service in k8s | `bool` | `false` | no |
| <a name="input_metrics_collection_interval"></a> [metrics\_collection\_interval](#input\_metrics\_collection\_interval) | Interval to collect the metrics in the instances for cloudwatch. | `number` | `60` | no |
| <a name="input_s3_expiration_days"></a> [s3\_expiration\_days](#input\_s3\_expiration\_days) | specified date or time period in the object's lifetime is reached. | `number` | `90` | no |
| <a name="input_s3_lifecycle_rule_enabled"></a> [s3\_lifecycle\_rule\_enabled](#input\_s3\_lifecycle\_rule\_enabled) | (Optional) Specifies lifecycle rule status. Defaults to Enabled | `string` | `"Enabled"` | no |
| <a name="input_s3_noncurrent_version_expiration_days"></a> [s3\_noncurrent\_version\_expiration\_days](#input\_s3\_noncurrent\_version\_expiration\_days) | The Expiration action results in Amazon S3 permanently removing the object. | `number` | `90` | no |
| <a name="input_s3_noncurrent_version_transition_glacier_days"></a> [s3\_noncurrent\_version\_transition\_glacier\_days](#input\_s3\_noncurrent\_version\_transition\_glacier\_days) | The objects to remain in the current storage class before Amazon S3 transitions them Glacier. | `number` | `30` | no |
| <a name="input_s3_transition_glacier_days"></a> [s3\_transition\_glacier\_days](#input\_s3\_transition\_glacier\_days) | The objects to remain in the current storage class before Amazon S3 transitions them Glacier. | `number` | `60` | no |
| <a name="input_s3_transition_standard_ia_days"></a> [s3\_transition\_standard\_ia\_days](#input\_s3\_transition\_standard\_ia\_days) | The objects to remain in the current storage class before Amazon S3 transitions them to STANDARD\_IA. | `number` | `30` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | (Optional) A list of associated security group IDS. | `list(string)` | `[]` | no |
| <a name="input_sns_topics"></a> [sns\_topics](#input\_sns\_topics) | List of SNS topics to execute when CloudWatch alarm changes it's state. Use it only if `enable_cloudwatch_alarms_per_worker_node` is true. | `list(string)` | `[]` | no |
| <a name="input_spot_launch_template_version"></a> [spot\_launch\_template\_version](#input\_spot\_launch\_template\_version) | Template version for spot instances. Can be version number, $Latest, or $Default. | `string` | `null` | no |
| <a name="input_spot_node_group_scaling_config"></a> [spot\_node\_group\_scaling\_config](#input\_spot\_node\_group\_scaling\_config) | Configuration block with scaling settings for spot instances | <pre>list(object({<br>    desired_size = number<br>    max_size     = number<br>    min_size     = number<br><br>  }))</pre> | `[]` | no |
| <a name="input_spot_node_group_taint"></a> [spot\_node\_group\_taint](#input\_spot\_node\_group\_taint) | (Optional) The Kubernetes taints to be applied to the nodes in the node group. Maximum of 50 taints per node group | <pre>list(object({<br>    key    = string<br>    value  = string<br>    effect = string<br><br>  }))</pre> | `[]` | no |
| <a name="input_spot_node_update_config"></a> [spot\_node\_update\_config](#input\_spot\_node\_update\_config) | update config for spot instance | <pre>list(object({<br>    max_unavailable            = number<br>    max_unavailable_percentage = number<br><br>  }))</pre> | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs to launch the cluster. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`). | `map(string)` | `{}` | no |
| <a name="input_thumbprint_list"></a> [thumbprint\_list](#input\_thumbprint\_list) | (Required) A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s). Default to 9e99a48a9960b14926bb7f3b02e22da2b0ab7280 | `string` | `"9e99a48a9960b14926bb7f3b02e22da2b0ab7280"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where EKS cluster has to be created. | `string` | n/a | yes |
| <a name="input_worker_key"></a> [worker\_key](#input\_worker\_key) | The ssh key name that should be used for the instance. | `string` | n/a | yes |
| <a name="input_worker_node_cpu_utilization_high"></a> [worker\_node\_cpu\_utilization\_high](#input\_worker\_node\_cpu\_utilization\_high) | `CPUUtilization` metric alarm configuration. | <pre>object({<br>    comparison_operator = string<br>    threshold           = number<br>    evaluation_periods  = number<br>    period              = number<br>    statistic           = string<br>  })</pre> | <pre>{<br>  "comparison_operator": "GreaterThanOrEqualToThreshold",<br>  "evaluation_periods": 2,<br>  "period": 300,<br>  "statistic": "Average",<br>  "threshold": 70<br>}</pre> | no |
| <a name="input_worker_node_disk_usage_high_xvda1"></a> [worker\_node\_disk\_usage\_high\_xvda1](#input\_worker\_node\_disk\_usage\_high\_xvda1) | `disk_used_percent` metric alarm configuration. Defaults to: `comparison_operator = GreaterThanOrEqualToThreshold`, `threshold = 70`, `evaluation_periods = 1`, `period = 60`, `statistic = Maximum` | <pre>object({<br>    comparison_operator = string<br>    threshold           = number<br>    evaluation_periods  = number<br>    period              = number<br>    statistic           = string<br>    dimensions          = map(string)<br><br>  })</pre> | <pre>{<br>  "comparison_operator": "GreaterThanOrEqualToThreshold",<br>  "dimensions": {<br>    "device": "xvda1",<br>    "fstype": "xfs",<br>    "path": "/"<br>  },<br>  "evaluation_periods": 1,<br>  "period": 60,<br>  "statistic": "Maximum",<br>  "threshold": 70<br>}</pre> | no |
| <a name="input_worker_node_disk_usage_high_xvdb"></a> [worker\_node\_disk\_usage\_high\_xvdb](#input\_worker\_node\_disk\_usage\_high\_xvdb) | `disk_used_percent` metric alarm configuration. | <pre>object({<br>    comparison_operator = string<br>    threshold           = number<br>    evaluation_periods  = number<br>    period              = number<br>    statistic           = string<br>    dimensions          = map(string)<br><br>  })</pre> | <pre>{<br>  "comparison_operator": "GreaterThanOrEqualToThreshold",<br>  "dimensions": {<br>    "device": "xvdb",<br>    "fstype": "xfs",<br>    "path": "/var/lib/docker"<br>  },<br>  "evaluation_periods": 1,<br>  "period": 60,<br>  "statistic": "Maximum",<br>  "threshold": 70<br>}</pre> | no |
| <a name="input_worker_node_memory_usage_high"></a> [worker\_node\_memory\_usage\_high](#input\_worker\_node\_memory\_usage\_high) | `mem_used_percent` metric alarm configuration. | <pre>object({<br>    comparison_operator = string<br>    threshold           = number<br>    evaluation_periods  = number<br>    period              = number<br>    statistic           = string<br>  })</pre> | <pre>{<br>  "comparison_operator": "GreaterThanOrEqualToThreshold",<br>  "evaluation_periods": 2,<br>  "period": 300,<br>  "statistic": "Average",<br>  "threshold": 80<br>}</pre> | no |
| <a name="input_workers_instance_type"></a> [workers\_instance\_type](#input\_workers\_instance\_type) | (Required) The size of instance to launch. | `string` | `"t3.medium"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | Eks Cluster Endpoint |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | Name of eks cluster |
| <a name="output_eks_cluster_oidc_issuer"></a> [eks\_cluster\_oidc\_issuer](#output\_eks\_cluster\_oidc\_issuer) | Issuer URL for the OpenID Connect identity provider |
| <a name="output_eks_cluster_sa_alb_role"></a> [eks\_cluster\_sa\_alb\_role](#output\_eks\_cluster\_sa\_alb\_role) | Service account Role for ALB Ingress |
| <a name="output_eks_cluster_sa_external_dns_role"></a> [eks\_cluster\_sa\_external\_dns\_role](#output\_eks\_cluster\_sa\_external\_dns\_role) | Service account Role for External DNS |
| <a name="output_eks_cluster_sg"></a> [eks\_cluster\_sg](#output\_eks\_cluster\_sg) | EKS cluster security group id |
| <a name="output_eks_spot_node_group_arn"></a> [eks\_spot\_node\_group\_arn](#output\_eks\_spot\_node\_group\_arn) | node group arn for spot |
| <a name="output_eks_worker_iam_role"></a> [eks\_worker\_iam\_role](#output\_eks\_worker\_iam\_role) | IAM Role for EKS Workers |
| <a name="output_eks_worker_sg"></a> [eks\_worker\_sg](#output\_eks\_worker\_sg) | EKS workers security group id |