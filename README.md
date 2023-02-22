# PVH Europe Labs - Terraform Modules

#### This Repo is intended to share PVH Best practices for EKS(AWS) and Kubernetes bootstrap using terraform for kubernetes-community-days-amsterdam-2023.

### Pre-Request

#### Providers
- terraform
- aws
- kubernetes
- helm

#### Overview
- eks - Module to bootstrap eks cluster in AWS.
- k8s-bootstrap - Bootstrap your EKS cluster with aws-auth(sso and iam user), karpenter, Ingress, External-DNS using kubernetes provider.