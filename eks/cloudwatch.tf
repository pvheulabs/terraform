resource "aws_cloudwatch_log_group" "instance_log_group" {
  name              = var.instance_log_group != null ? format("/eks/%s-instance-log-group", var.instance_log_group) : format("/eks/%s-instance-log-group", var.eks_cluster_name)
  retention_in_days = var.cloudwatch_log_retention_days
  tags              = merge(var.tags, tomap({ "Name" = format("%s", var.eks_cluster_name) }))
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = format("%s-mem-util-high-agents", var.eks_cluster_name)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_memory_high
  alarm_description   = "This metric monitors ec2 memory for high utilization on agent hosts"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.worker_ag_group.name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  alarm_name          = format("%s-mem-util-low-agents", var.eks_cluster_name)
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_memory_low
  alarm_description   = "This metric monitors ec2 memory for low utilization on agent hosts"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.worker_ag_group.name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = format("%s-CPU-Utilization-High", var.eks_cluster_name)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_cpu_high

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.worker_ag_group.name
  }

  alarm_description = "This metric monitors ec2 CPU for high utilization on agent hosts"
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name          = format("%s-CPU-Utilization-Low", var.eks_cluster_name)
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_cpu_low

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.worker_ag_group.name
  }

  alarm_description = "This metric monitors ec2 CPU for low utilization on agent hosts"
  tags              = var.tags
}

// Additional CW Alarms
data "aws_instances" "eks_worker_nodes" {
  count = var.cloudwatch_agent_config_type == "advanced" && var.enable_cloudwatch_alarms_per_worker_node ? 1 : 0
  instance_tags = {
    Name = aws_eks_cluster.ekscluster.name
  }

  instance_state_names = ["running"]

  depends_on = [
    aws_autoscaling_group.worker_ag_group
  ]
}

resource "aws_cloudwatch_metric_alarm" "worker_node_cpu_utilization_high" {
  count                     = local.enable_worker_node_alarms
  alarm_name                = format("EKS-worker-node-%s-cpu-high", data.aws_instances.eks_worker_nodes[0].ids[count.index])
  comparison_operator       = var.worker_node_cpu_utilization_high.comparison_operator
  threshold                 = var.worker_node_cpu_utilization_high.threshold
  unit                      = "Percent"
  evaluation_periods        = var.worker_node_cpu_utilization_high.evaluation_periods
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = var.worker_node_cpu_utilization_high.period
  statistic                 = var.worker_node_cpu_utilization_high.statistic
  alarm_description         = format("Worker Node CPU Utilization over %s%s", var.worker_node_cpu_utilization_high.threshold, "%")
  insufficient_data_actions = []
  treat_missing_data        = "ignore"


  dimensions = {
    InstanceId = data.aws_instances.eks_worker_nodes[0].ids[count.index]
  }

  alarm_actions = var.sns_topics
  ok_actions    = var.sns_topics

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "worker_node_memory_usage_high" {
  count                     = local.enable_worker_node_alarms
  alarm_name                = format("EKS-worker-node-%s-memory-high", data.aws_instances.eks_worker_nodes[0].ids[count.index])
  comparison_operator       = var.worker_node_memory_usage_high.comparison_operator
  threshold                 = var.worker_node_memory_usage_high.threshold
  unit                      = "Percent"
  evaluation_periods        = var.worker_node_memory_usage_high.evaluation_periods
  metric_name               = "mem_used_percent"
  namespace                 = "CWAgent"
  period                    = var.worker_node_memory_usage_high.period
  statistic                 = var.worker_node_memory_usage_high.statistic
  alarm_description         = format("Worker Node Memory Usage over %s%s", var.worker_node_memory_usage_high.threshold, "%")
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  dimensions = {
    InstanceId = data.aws_instances.eks_worker_nodes[0].ids[count.index]
  }

  alarm_actions = var.sns_topics
  ok_actions    = var.sns_topics

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "worker_node_disk_usage_high_xvda1" {
  count                     = local.enable_worker_node_alarms
  alarm_name                = format("EKS-worker-node-%s-disk-%s-usage-high", data.aws_instances.eks_worker_nodes[0].ids[count.index], var.worker_node_disk_usage_high_xvda1.dimensions.device)
  comparison_operator       = var.worker_node_disk_usage_high_xvda1.comparison_operator
  threshold                 = var.worker_node_disk_usage_high_xvda1.threshold
  unit                      = "Percent"
  evaluation_periods        = var.worker_node_disk_usage_high_xvda1.evaluation_periods
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = var.worker_node_disk_usage_high_xvda1.period
  statistic                 = var.worker_node_disk_usage_high_xvda1.statistic
  alarm_description         = format("Worker Node Disk %s, Usage over %s%s", var.worker_node_disk_usage_high_xvda1.dimensions.device, var.worker_node_disk_usage_high_xvda1.threshold, "%")
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  dimensions = {
    InstanceId           = data.aws_instances.eks_worker_nodes[0].ids[count.index]
    AutoScalingGroupName = aws_autoscaling_group.worker_ag_group.name
    device               = var.worker_node_disk_usage_high_xvda1.dimensions.device
    fstype               = var.worker_node_disk_usage_high_xvda1.dimensions.fstype
    path                 = var.worker_node_disk_usage_high_xvda1.dimensions.path
  }

  alarm_actions = var.sns_topics
  ok_actions    = var.sns_topics

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "worker_node_disk_usage_high_xvdb" {
  count                     = local.enable_worker_node_alarms
  alarm_name                = format("EKS-worker-node-%s-disk-%s-usage-high", data.aws_instances.eks_worker_nodes[0].ids[count.index], var.worker_node_disk_usage_high_xvdb.dimensions.device)
  comparison_operator       = var.worker_node_disk_usage_high_xvdb.comparison_operator
  threshold                 = var.worker_node_disk_usage_high_xvdb.threshold
  unit                      = "Percent"
  evaluation_periods        = var.worker_node_disk_usage_high_xvdb.evaluation_periods
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = var.worker_node_disk_usage_high_xvdb.period
  statistic                 = var.worker_node_disk_usage_high_xvdb.statistic
  alarm_description         = format("Worker Node Disk %s, Usage over %s%s", var.worker_node_disk_usage_high_xvdb.dimensions.device, var.worker_node_disk_usage_high_xvdb.threshold, "%")
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  dimensions = {
    InstanceId           = data.aws_instances.eks_worker_nodes[0].ids[count.index]
    AutoScalingGroupName = aws_autoscaling_group.worker_ag_group.name
    device               = var.worker_node_disk_usage_high_xvdb.dimensions.device
    fstype               = var.worker_node_disk_usage_high_xvdb.dimensions.fstype
    path                 = var.worker_node_disk_usage_high_xvdb.dimensions.path
  }

  alarm_actions = var.sns_topics
  ok_actions    = var.sns_topics

  tags = var.tags
}

locals {
  enable_worker_node_alarms = var.cloudwatch_agent_config_type == "advanced" && var.enable_cloudwatch_alarms_per_worker_node ? var.autoscale_minsize : 0
}
