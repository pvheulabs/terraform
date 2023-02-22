resource "aws_launch_template" "instances_template" {
  name                   = format("%s-launch-template", var.eks_cluster_name)
  image_id               = data.aws_ami.eks_worker.id
  instance_type          = var.workers_instance_type
  key_name               = var.worker_key
  vpc_security_group_ids = concat(tolist([aws_security_group.eks_worker_sg.id]), var.security_groups)
  iam_instance_profile {
    name = aws_iam_instance_profile.eks-worker-profile.name
  }
  user_data = base64encode(templatefile(format("%s/templates/eks_userdata.sh.tpl", path.module),
    {
      log_group                    = aws_cloudwatch_log_group.instance_log_group.name
      cloudwatch_agent_install     = var.enable_cloudwatch_agent_install
      cloudwatch_agent_config_type = var.cloudwatch_agent_config_type
      metrics_collection_interval  = var.metrics_collection_interval
      total_cpu_value              = var.enable_cloudwatch_agent_cpu_per_core_metrics
      cluster_cert                 = aws_eks_cluster.ekscluster.certificate_authority.0.data
      cluster_endpoint             = aws_eks_cluster.ekscluster.endpoint
      container_runtime            = var.eks_container_runtime
      cluster_name                 = var.eks_cluster_name
      cpu_resources                = var.cpu_resources
      device_docker                = local.device_docker
      kubelet-extra-args           = "" # empty value for on-demand
      more_additional_user_data    = var.additional_user_data
  }))
  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = try(block_device_mappings.value.no_device, null)
      virtual_name = try(block_device_mappings.value.virtual_name, null)
      dynamic "ebs" {
        for_each = flatten([
        try(block_device_mappings.value.ebs, [])])
        content {
          delete_on_termination = try(ebs.value.delete_on_termination, null)
          encrypted             = try(ebs.value.encrypted, null)
          kms_key_id            = try(ebs.value.kms_key_id, null)
          iops                  = try(ebs.value.iops, null)
          throughput            = try(ebs.value.throughput, null)
          snapshot_id           = try(ebs.value.snapshot_id, null)
          volume_size           = try(ebs.value.volume_size, null)
          volume_type           = try(ebs.value.volume_type, null)
        }
      }
    }
  }
  monitoring {
    enabled = var.enable_detailed_monitoring
  }
  lifecycle {
    create_before_destroy = true
  }
}

// Launch template for spot - Since iam_instance_profile is not supported in launch_template for spot

resource "aws_launch_template" "spot_instances_template" {
  count                  = local.spot_count
  name                   = format("%s-spot-launch-template", var.eks_cluster_name)
  image_id               = data.aws_ami.eks_worker.id
  instance_type          = var.workers_instance_type
  key_name               = var.worker_key
  vpc_security_group_ids = concat(tolist([aws_security_group.eks_worker_sg.id]), var.security_groups)
  user_data = base64encode(templatefile(format("%s/templates/eks_userdata.sh.tpl", path.module),
    {
      log_group                    = aws_cloudwatch_log_group.instance_log_group.name
      cloudwatch_agent_install     = var.enable_cloudwatch_agent_install
      cloudwatch_agent_config_type = var.cloudwatch_agent_config_type
      metrics_collection_interval  = var.metrics_collection_interval
      total_cpu_value              = var.enable_cloudwatch_agent_cpu_per_core_metrics
      cluster_cert                 = aws_eks_cluster.ekscluster.certificate_authority.0.data
      cluster_endpoint             = aws_eks_cluster.ekscluster.endpoint
      container_runtime            = var.eks_container_runtime
      cluster_name                 = var.eks_cluster_name
      cpu_resources                = var.cpu_resources
      device_docker                = local.device_docker
      kubelet-extra-args           = format("eks.amazonaws.com/nodegroup=%s-spot-ng", var.eks_cluster_name)
      more_additional_user_data    = var.additional_user_data
  }))
  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = try(block_device_mappings.value.no_device, null)
      virtual_name = try(block_device_mappings.value.virtual_name, null)
      dynamic "ebs" {
        for_each = flatten([
        try(block_device_mappings.value.ebs, [])])
        content {
          delete_on_termination = try(ebs.value.delete_on_termination, null)
          encrypted             = try(ebs.value.encrypted, null)
          kms_key_id            = try(ebs.value.kms_key_id, null)
          iops                  = try(ebs.value.iops, null)
          throughput            = try(ebs.value.throughput, null)
          snapshot_id           = try(ebs.value.snapshot_id, null)
          volume_size           = try(ebs.value.volume_size, null)
          volume_type           = try(ebs.value.volume_type, null)
        }
      }
    }
  }
  monitoring {
    enabled = var.enable_detailed_monitoring
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "worker_ag_group" {
  desired_capacity = var.autoscale_desired_size
  launch_template {
    id      = aws_launch_template.instances_template.id
    version = var.launch_template_version
  }

  max_size                  = var.autoscale_maxsize
  min_size                  = var.autoscale_minsize
  name                      = format("%s-worker-autoscale", var.eks_cluster_name)
  vpc_zone_identifier       = var.subnet_ids
  termination_policies      = var.asg_termination_policies
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = "EC2"
  dynamic "instance_refresh" {
    for_each = var.enable_instance_refresh ? var.instance_refresh : []
    content {
      strategy = instance_refresh.value.strategy
      dynamic "preferences" {
        for_each = try([instance_refresh.value.preferences], [])
        content {
          checkpoint_delay       = try(preferences.value.checkpoint_delay, null)
          checkpoint_percentages = try(preferences.value.checkpoint_percentages, null)
          instance_warmup        = try(preferences.value.instance_warmup, null)
          min_healthy_percentage = try(preferences.value.min_healthy_percentage, null)
        }
      }
      triggers = instance_refresh.value.triggers
    }
  }
  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

}
