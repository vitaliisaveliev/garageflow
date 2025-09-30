variable "ingress_nginx_version" {
  type        = string
  default     = "4.10.1"
  description = "Helm chart version for ingress-nginx"
}

variable "cert_manager_version" {
  type        = string
  default     = "v1.13.2"
  description = "Helm chart version for cert-manager"
}

variable "argocd_version" {
  type        = string
  default     = "6.7.8"
  description = "Helm chart version for ArgoCD"
}

variable "argocd_host" {
  type        = string
  default     = "argocd.localhost"
  description = "Host for ArgoCD ingress"
}
