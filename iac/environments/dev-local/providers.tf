terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
  config_context = "k3d-garageflow-dev"
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
    config_context = "k3d-garageflow-dev"
  }
}
