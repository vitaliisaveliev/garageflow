terraform {
  required_version = ">= 1.6.0"
  required_providers {
    helm       = { source = "hashicorp/helm",       version = "~> 2.12" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.26" }
  }
}

provider "kubernetes" {
  alias       = "local"
  config_path = pathexpand("~/.kube/config")
}

provider "helm" {
  alias = "local"
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}
