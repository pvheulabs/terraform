variable "vpc_id" {
  description = "VPC ID where EKS cluster has to be created."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch the cluster."
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "eks cluster name."
  type        = string
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks to be allowed to connect to the EKS cluster."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)."
  type        = map(string)
  default     = {}
}

variable "autoscale_desired_size" {
  description = "desired capacity size of the auto scale group."
  type        = number
  default     = 1
}

variable "autoscale_maxsize" {
  description = "The maximum size of the auto scale group."
  type        = number
  default     = 2
}

variable "autoscale_minsize" {
  description = "The minimum size of the auto scale group."
  type        = number
  default     = 1
}

variable "workers_instance_type" {
  description = "(Required) The size of instance to launch."
  type        = string
  default     = "t3.medium"
}

variable "worker_key" {
  description = "The ssh key name that should be used for the instance."
  type        = string
}

variable "cloudwatch_log_retention_days" {
  description = "(Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = 7
}

variable "instance_log_group" {
  description = "(Optional, Forces new resource) The name of the log group. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "additional_user_data" {
  description = "Addtional user data that will be executed after the instance joins the cluster. Defaults to echo no additional user data provided."
  type        = string
  default     = "echo 'no additional user data provided'"
}

variable "security_groups" {
  description = "(Optional) A list of associated security group IDS."
  type        = list(string)
  default     = []
}

variable "cpu_resources" {
  description = "Specifies that per-cpu metrics are to be collected. The only allowed value is *. If you include this field and value, per-cpu metrics are collected."
  type        = string
  default     = "\"resources\": [\"*\"],"
}

variable "metrics_collection_interval" {
  description = "Interval to collect the metrics in the instances for cloudwatch."
  type        = number
  default     = 60
}

variable "alarm_memory_high" {
  description = "(Optional) The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds, but should not be used for alarms based on anomaly detection models. Value to high Memory threshold."
  type        = number
  default     = 80
}

variable "alarm_memory_low" {
  description = " (Optional) The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds, but should not be used for alarms based on anomaly detection models.Value to low Memory threshold."
  type        = number
  default     = 40
}

variable "alarm_cpu_high" {
  description = "(Optional) The high CPU  threshold percentage."
  type        = number
  default     = 20
}

variable "alarm_cpu_low" {
  description = "(Optional) The Low CPU threshold percentage."
  type        = number
  default     = 20
}

variable "ami_owner_id" {
  description = "(Required) List of AMI owners to limit search. At least 1 value must be specified. Valid values: an AWS account ID, self (the current account), or an AWS owner alias (e.g. amazon, aws-marketplace, microsoft)."
  type        = string
}

variable "eks_version" {
  description = " The Kubernetes server version for the cluster. If you do not specify a value, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS. The value must be configured and increased to upgrade the version when desired. Downgrades are not supported by EKS."
  type        = string
  default     = "1.23"
}

variable "application_tag" {
  description = "A list of tag blocks for autoscaling group."
  type        = string
  default     = "EKS"
}
variable "eks_image_regex" {
  description = "(Optional) A regex string to apply to the AMI list returned by AWS."
  type        = string
}

variable "eks_container_runtime" {
  description = "Specify a container runtime. Allowed values:: 'dockerd', 'containerd'"
  type        = string
  default     = "containerd"
}

variable "block_device_mappings" {
  description = "Block devices attached to worker nodes. By default root volume will be 20G and other volume will be 100G will be attached to instances. device names are valid only for PVH-ISG-Amazon-Linux-EKS image."
  type        = list(any)
  default = [{
    device_name = "/dev/xvda"
    ebs = {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp3"
    } }, {
    device_name = "/dev/xvdb"
    ebs = {
      delete_on_termination = true
      volume_size           = 100
      volume_type           = "gp3"

  } }]

}

variable "asg_termination_policies" {
  description = "(Optional) A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default."
  type        = list(string)
  default     = ["OldestInstance"]
}

variable "create_eks_clusterautoscaler_policy" {
  description = "Attach additional policy for EKS cluster autoscaler."
  type        = bool
  default     = true
}

#ALB Support
variable "create_alb_policy" {
  description = "Attach additional policy for alb ingress."
  type        = bool
  default     = true
}


#Cloudwatch support
variable "enable_cloudwatch_agent_install" {
  description = "Enable this variable to install cloudwatch agent on worker nodes."
  type        = bool
  default     = true
}

variable "cloudwatch_agent_config_type" {
  description = "Type of cloudwatch wizard required. Allowed values: standard, advanced."
  type        = string
  default     = "standard"
}

variable "enable_cloudwatch_agent_cpu_per_core_metrics" {
  description = "Enable to monitor cpu usage per core level, it involves additional cost."
  type        = bool
  default     = false
}

variable "enable_cloudwatch_alarms_per_worker_node" {
  description = "Enable CloudWatch Alarms for each worker node. Using Terraform 13 is recommended, please read the Notes. cloudwatch_agent_config_type needs to be `advanced`. Metrics are `CPUUtilization`, `mem_used_percent` and `disk_used_percent` for `/` and `/var/lib/docker`."
  type        = bool
  default     = false
}

variable "sns_topics" {
  description = "List of SNS topics to execute when CloudWatch alarm changes it's state. Use it only if `enable_cloudwatch_alarms_per_worker_node` is true."
  type        = list(string)
  default     = []
}

variable "worker_node_cpu_utilization_high" {
  description = "`CPUUtilization` metric alarm configuration."
  type = object({
    comparison_operator = string
    threshold           = number
    evaluation_periods  = number
    period              = number
    statistic           = string
  })
  default = {
    comparison_operator = "GreaterThanOrEqualToThreshold"
    threshold           = 70
    evaluation_periods  = 2
    period              = 300
    statistic           = "Average"
  }
}

variable "worker_node_memory_usage_high" {
  description = "`mem_used_percent` metric alarm configuration."
  type = object({
    comparison_operator = string
    threshold           = number
    evaluation_periods  = number
    period              = number
    statistic           = string
  })
  default = {
    comparison_operator = "GreaterThanOrEqualToThreshold"
    threshold           = 80
    evaluation_periods  = 2
    period              = 300
    statistic           = "Average"
  }
}

variable "worker_node_disk_usage_high_xvda1" {
  description = "`disk_used_percent` metric alarm configuration. Defaults to: `comparison_operator = GreaterThanOrEqualToThreshold`, `threshold = 70`, `evaluation_periods = 1`, `period = 60`, `statistic = Maximum`"
  type = object({
    comparison_operator = string
    threshold           = number
    evaluation_periods  = number
    period              = number
    statistic           = string
    dimensions          = map(string)

  })
  default = {
    comparison_operator = "GreaterThanOrEqualToThreshold"
    threshold           = 70
    evaluation_periods  = 1
    period              = 60
    statistic           = "Maximum"
    dimensions = {
      device = "xvda1"
      fstype = "xfs"
      path   = "/"
    }
  }
}

variable "worker_node_disk_usage_high_xvdb" {
  description = "`disk_used_percent` metric alarm configuration."
  type = object({
    comparison_operator = string
    threshold           = number
    evaluation_periods  = number
    period              = number
    statistic           = string
    dimensions          = map(string)

  })
  default = {
    comparison_operator = "GreaterThanOrEqualToThreshold"
    threshold           = 70
    evaluation_periods  = 1
    period              = 60
    statistic           = "Maximum"
    dimensions = {
      device = "xvdb"
      fstype = "xfs"
      path   = "/var/lib/docker"
    }
  }
}

#ALB log bucket
variable "force_destroy" {
  description = "Optional A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = true
}

variable "alb_log_bucket_name" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "s3_lifecycle_rule_enabled" {
  description = "(Optional) Specifies lifecycle rule status. Defaults to Enabled"
  type        = string
  default     = "Enabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.s3_lifecycle_rule_enabled)
    error_message = "Invalid value for s3_lifecycle_rule_enabled."
  }

}

variable "s3_noncurrent_version_expiration_days" {
  description = "The Expiration action results in Amazon S3 permanently removing the object."
  type        = number
  default     = 90
}

variable "s3_noncurrent_version_transition_glacier_days" {
  description = "The objects to remain in the current storage class before Amazon S3 transitions them Glacier."
  type        = number
  default     = 30
}

variable "s3_transition_standard_ia_days" {
  description = "The objects to remain in the current storage class before Amazon S3 transitions them to STANDARD_IA."
  type        = number
  default     = 30
}

variable "s3_transition_glacier_days" {
  description = "The objects to remain in the current storage class before Amazon S3 transitions them Glacier."
  type        = number
  default     = 60
}

variable "s3_expiration_days" {
  description = "specified date or time period in the object's lifetime is reached."
  type        = number
  default     = 90
}

variable "create_service_accounts_role" {
  description = "(Optional) create services accounts for alb-ingress and external dns"
  type        = bool
  default     = false
}

variable "thumbprint_list" {
  description = "(Required) A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s). Default to 9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
  type        = string
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "external_dns_zone_ids" {
  description = "List of ZoneID's that can be managed by external dns service account"
  type        = list(string)
  default     = []
}

variable "health_check_grace_period" {
  description = "(Optional, Default: 300) Time (in seconds) after instance comes into service before checking health."
  type        = number
  default     = 300
}

variable "enable_instance_refresh" {
  description = "Enable Instance refresh for autoscaling group"
  type        = bool
  default     = false
}

variable "manage_external_dns" {
  description = "Manage the zone via external dns service in k8s"
  type        = bool
  default     = false
}

variable "instance_refresh" {
  description = "(Optional) If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated. Refer https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#instance_refresh"
  type = list(object({
    strategy = string
    preferences = object({
      checkpoint_delay       = number
      checkpoint_percentages = list(number)
      instance_warmup        = number
      min_healthy_percentage = number

    })
    triggers = list(string)
  }))
  default = [{
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = null
      checkpoint_percentages = null
      instance_warmup        = null
      min_healthy_percentage = 50
    }
    triggers = ["launch_configuration"]
  }]
}

variable "enable_spot_instances" {
  description = "set to true if you need spot instances in the launch configuration. Default to false"
  type        = bool
  default     = false
}

variable "manage_karpenter" {
  description = "Manage the Cluster Scaling with karpenter service in k8s"
  type        = bool
  default     = false
}
variable "manage_cluster_autoscaler" {
  description = "Manage the Cluster Scaling with Cluster Autoscaler service in k8s"
  type        = bool
  default     = false
}

// launch templates

variable "launch_template_version" {
  description = "Template version. Can be version number, $Latest, or $Default."
  type        = string
  default     = "$Latest"
}

variable "spot_launch_template_version" {
  description = "Template version for spot instances. Can be version number, $Latest, or $Default."
  type        = string
  default     = null
}

variable "enable_detailed_monitoring" {
  description = "Enable this to have launched EC2 instance will have detailed monitoring enabled."
  type        = bool
  default     = false
}

#variable "mixed_instances_instances_distribution" {
#  description = "mixed instance policy for launch template. Refer https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#launch_template_specification. spot_instance_pools Only available with spot_allocation_strategy set to lowest-price. Otherwise it must be set to 0, if it has been defined before"
#  type = list(object({
#    on_demand_allocation_strategy            = string
#    on_demand_base_capacity                  = number
#    on_demand_percentage_above_base_capacity = number
#    spot_allocation_strategy                 = string
#    spot_instance_pools                      = number
#    spot_max_price                           = string
#  }))
#  default = []
#}

variable "spot_node_group_scaling_config" {
  description = "Configuration block with scaling settings for spot instances"
  type = list(object({
    desired_size = number
    max_size     = number
    min_size     = number

  }))
  default = []

}

variable "spot_node_update_config" {
  description = "update config for spot instance"
  type = list(object({
    max_unavailable            = number
    max_unavailable_percentage = number

  }))
  default = []
}

variable "spot_node_group_taint" {
  description = "(Optional) The Kubernetes taints to be applied to the nodes in the node group. Maximum of 50 taints per node group"
  type = list(object({
    key    = string
    value  = string
    effect = string

  }))
  default = []

}
