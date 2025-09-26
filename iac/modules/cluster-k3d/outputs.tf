output "cluster_name" {
  value = var.cluster_name
}

output "kubeconfig_path" {
  value = pathexpand("~/.kube/config")
}
