// Namespace

resource "kubernetes_namespace" "namespace" {
  count = length(var.k8s_application_namespace) > 0 ? 1 : 0
  metadata {
    name = var.k8s_application_namespace[count.index]
  }
}

// AUTH CONFIG

resource "kubernetes_config_map" "aws_auth" {
  count = local.create_aws_auth
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = templatefile(format("%s/templates/eks_aws_auth_map_roles.tpl", path.module), {
      aws_account_id   = var.aws_account_id
      eks_cluster_name = var.eks_cluster_name
      sso_admin_roles  = var.sso_admin_roles_name
      deployment_roles = var.deployment_roles_name
    })
    mapUsers = templatefile(format("%s/templates/eks_aws_auth_map_users.tpl", path.module), {
      aws_account_id  = var.aws_account_id,
      eks_admin_users = var.eks_admin_users
    })

  }
}

// Service Accounts to MAP IAM Role.

resource "kubernetes_service_account" "external_dns" {
  count = local.create_external_dns
  metadata {
    name = local.external_dns_name
    annotations = {
      "eks.amazonaws.com/role-arn" = format("arn:aws:iam::%s:role/%s-sa-externaldns-role", var.aws_account_id, var.eks_cluster_name)
    }
  }
}

resource "kubernetes_service_account" "ingress" {
  count = local.create_ingress_controller
  metadata {
    name      = local.ingress_serviceaccount_name
    namespace = var.helm_namespaces.alb-ingress
    annotations = {
      "eks.amazonaws.com/role-arn" = format("arn:aws:iam::%s:role/%s-sa-alb-role", var.aws_account_id, var.eks_cluster_name)
    }
  }
}

// External dns

resource "kubernetes_cluster_role" "external_dns" {
  count = local.create_external_dns
  metadata {
    name = local.external_dns_name
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints", "services", "pods"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]

  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list", "watch"]
  }
  depends_on = [kubernetes_service_account.external_dns]
}


resource "kubernetes_cluster_role_binding" "external_dns" {
  count = local.create_external_dns
  metadata {
    name = format("%s-viewer", local.external_dns_name)
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_dns[0].metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.external_dns[0].metadata.0.name
    namespace = kubernetes_service_account.external_dns[0].metadata.0.namespace
  }
  depends_on = [kubernetes_cluster_role.external_dns]
}


resource "kubernetes_deployment" "external_dns" {
  count = local.create_external_dns
  metadata {
    name      = local.external_dns_name
    namespace = var.helm_namespaces.external-dns
  }

  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = local.external_dns_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.external_dns_name
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.external_dns[0].metadata.0.name
        automount_service_account_token = true
        container {
          name  = local.external_dns_name
          image = format("%s:%s", var.external_dns_image, var.external_dns_image_tag)
          args = [
            "--source=service",
            "--source=ingress",
            format("--domain-filter=%s", var.dns_zone_name),
            "--provider=aws",
            "--policy=upsert-only",
            format("--aws-zone-type=%s", var.external_dns_aws_zone_type),
            "--registry=txt",
            format("--txt-owner-id=%s", var.eks_cluster_name)
          ]
        }
        security_context {
          fs_group = 65534
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_account.external_dns,
    kubernetes_cluster_role.external_dns
  ]
}


//Ingress


resource "helm_release" "aws_alb_ingress_controller" {
  count      = local.create_ingress_controller
  name       = local.ingress_serviceaccount_name
  namespace  = var.helm_namespaces.alb-ingress
  chart      = local.ingress_serviceaccount_name
  repository = var.alb_ingress_helm_chart_repository
  version    = var.alb_ingress_helm_chart_version

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
  set {
    name  = "autoDiscoverAwsRegion"
    value = true
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = true
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = local.ingress_serviceaccount_name
  }
  set {
    name  = "image.tag"
    value = var.alb_ingress_image_tag
  }
}

// fluent-bit configuration

resource "kubernetes_namespace" "fluent-bit_namespace" {
  count = local.create_fluent-bit
  metadata {
    name = var.fluent-bit_namespace
  }
}

resource "kubernetes_service_account" "fluent-bit" {
  count = local.create_fluent-bit
  metadata {
    name      = "fluent-bit"
    namespace = var.fluent-bit_namespace
  }
}

resource "kubernetes_cluster_role" "fluent-bit" {
  count = local.create_fluent-bit
  metadata {
    name = "fluent-bit-role"
  }
  rule {
    api_groups = [""]
    verbs      = ["get", "list", "watch"]
    resources  = ["pods/logs", "namespaces", "pods"]
  }
  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "fluent-bit" {
  count = local.create_fluent-bit
  metadata {
    name = "fluent-bit-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "fluent-bit-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "fluent-bit"
    namespace = var.fluent-bit_namespace
  }
}

resource "kubernetes_manifest" "fluent-bit_configmaps" {
  count    = local.create_fluent-bit
  manifest = yamldecode(file(format("%s/templates/eks_aws_fluentbit_config_maps.yaml", path.module)))
}

resource "kubernetes_manifest" "fluent-bit-cluster-info" {
  count    = local.create_fluent-bit
  manifest = yamldecode(file(format("%s/templates/eks_aws_fluent_bit_cluster_info.yaml", path.module)))
}

resource "kubernetes_daemonset" "fluent-bit" {
  count = local.create_fluent-bit
  metadata {
    name      = "fluent-bit"
    namespace = var.fluent-bit_namespace
    labels = {
      k8s-app                         = "fluent-bit"
      version                         = "v1"
      "kubernetes.io/cluster-service" = "true"
    }
  }
  spec {
    selector {
      match_labels = {
        k8s-app = "fluent-bit"
      }
    }
    template {
      metadata {
        labels = {
          k8s-app                         = "fluent-bit"
          version                         = "v1"
          "kubernetes.io/cluster-service" = "true"
        }
      }
      spec {
        service_account_name            = "fluent-bit"
        automount_service_account_token = true
        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
        container {
          name  = "fluent-bit"
          image = format("%s:%s", var.fluent-bit_image, var.fluent-bit_image_tag)
          env {
            name  = "AWS_REGION"
            value = data.aws_region.current.name
          }
          env {
            name  = "CLUSTER_NAME"
            value = var.eks_cluster_name
          }
          env {
            name = "HTTP_SERVER"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "http.server"
              }
            }
          }
          env {
            name = "HTTP_PORT"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "http.port"
              }
            }
          }
          env {
            name = "READ_FROM_HEAD"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "read.head"
              }
            }
          }
          env {
            name = "READ_FROM_TAIL"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "read.tail"
              }
            }
          }
          env {
            name = "HOST_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          env {
            name  = "CI_VERSION"
            value = var.ci_version
          }
          resources {
            limits = {
              cpu    = var.fluent-bit_limit_cpu
              memory = var.fluent-bit_limit_memory
            }
            requests = {
              cpu    = var.fluent-bit_request_cpu
              memory = var.fluent-bit_request_memory
            }
          }
          volume_mount {
            mount_path = "/var/fluent-bit/state"
            name       = "fluentbitstate"
          }
          volume_mount {
            mount_path = "/var/log"
            name       = "varlog"
            read_only  = true
          }
          volume_mount {
            mount_path = "/var/lib/docker/containers"
            name       = "varlibdockercontainers"
            read_only  = true
          }
          volume_mount {
            mount_path = "/fluent-bit/etc/"
            name       = "fluent-bit-config"
          }
          volume_mount {
            mount_path = "/run/log/journal"
            name       = "runlogjournal"
            read_only  = true
          }
          volume_mount {
            mount_path = "/var/log/dmesg"
            name       = "dmesg"
            read_only  = true
          }
        }
        termination_grace_period_seconds = 10
        volume {
          name = "fluentbitstate"
          host_path {
            path = "/var/fluent-bit/state"
          }
        }
        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }
        volume {
          name = "fluent-bit-config"
          config_map {
            name = "fluent-bit-config"
          }
        }
        volume {
          name = "runlogjournal"
          host_path {
            path = "/run/log/journal"
          }
        }
        volume {
          name = "dmesg"
          host_path {
            path = "/var/log/dmesg"
          }
        }
      }
    }
  }
}

// karpenter

resource "helm_release" "karpenter" {
  count            = local.create_karpenter
  namespace        = local.karpenter_namespace
  create_namespace = local.create_karpenter_namespace
  name             = local.karpenter_name
  repository       = var.karpenter_helm_repository
  chart            = local.karpenter_chart_name
  version          = var.karpenter_helm_chart_version

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = format("arn:aws:iam::%s:role/%s-sa-karpenter-role", var.aws_account_id, var.eks_cluster_name)
  }

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "clusterEndpoint"
    value = var.cluster_endpoint
  }
}

// Cluster Autoscaller
resource "helm_release" "cluster_autoscaler" {
  count      = local.create_cluster_autoscaler
  name       = local.cluster_autoscaler_name
  chart      = local.cluster_autoscaler_chart_name
  repository = var.cluster_autoscaler_helm_repository
  version    = var.cluster_autoscaler_helm_chart_version
  namespace  = "kube-system"

  set {
    name  = "fullnameOverride"
    value = "cluster-autoscaler"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = local.cluster_autoscaler_name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = format("arn:aws:iam::%s:role/%s-sa-cluster_autoscaler-role", var.aws_account_id, var.eks_cluster_name)
  }

}

// reloader

resource "helm_release" "reloader" {
  count      = local.create_reloader
  name       = local.reloader_name
  chart      = local.reloader_chart_name
  repository = var.reloader_helm_repository
  version    = var.reloader_helm_chart_version
  namespace  = "kube-system"
}