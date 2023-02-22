terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws        = ">= 3.0, <= 4.0"
    helm       = ">= 2.0, <= 3.0"
    kubernetes = ">= 2.0, <= 3.0"
  }
}