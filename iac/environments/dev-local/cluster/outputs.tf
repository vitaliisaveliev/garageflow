output "kubeconfig_path" {
  description = "Kubeconfig path from the cluster module"
  value       = module.cluster_k3d.kubeconfig_path
}

output "kube_context" {
  description = "Kubeconfig context from the cluster module"
  value       = module.cluster_k3d.kube_context
}
