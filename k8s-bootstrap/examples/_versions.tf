terraform {
  required_version = "v1.1.11"
  backend "s3" {
    bucket         = "other-provider-state"
    key            = "terraform.tfstate"
    dynamodb_table = "other-provider-state-lock"
    region         = "eu-central-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
  }
}

provider "aws" {
  alias = "awswest"
  region  = "eu-central-1"
  assume_role {
    role_arn = format("arn:aws:iam::%s:role/TerraformCrossAccountRole", var.aws_account_ids[terraform.workspace])
  }
}

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
