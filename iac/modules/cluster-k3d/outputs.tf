output "cluster_name" {
  description = "Cluster name"
  value       = var.cluster_name
}

output "kubeconfig_path" {
  description = "Path to kubeconfig used for this cluster"
  value       = pathexpand("~/.kube/config")
}

output "kube_context" {
  description = "Kubeconfig context for the created k3d cluster"
  value       = "k3d-${var.cluster_name}"
}
