terraform {
  required_version = ">= 1.6.0"

  required_providers {
    helm       = { source = "hashicorp/helm", version = "~> 2.12" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.26" }
  }
}

# Подтягиваем стейт кластера
data "terraform_remote_state" "cluster" {
  backend = "local"
  config = {
    path = "../cluster/terraform.tfstate"
  }
}

# Kubernetes provider
provider "kubernetes" {
  alias          = "local"
  config_path    = data.terraform_remote_state.cluster.outputs.kubeconfig_path
  config_context = data.terraform_remote_state.cluster.outputs.kube_context
}

# Helm provider (на том же контексте)
provider "helm" {
  alias = "local"

  kubernetes {
    config_path    = data.terraform_remote_state.cluster.outputs.kubeconfig_path
    config_context = data.terraform_remote_state.cluster.outputs.kube_context
  }
}
