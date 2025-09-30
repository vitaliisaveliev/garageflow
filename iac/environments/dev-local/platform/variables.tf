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

variable "postgresql_version" {
  type        = string
  default     = "15.2.2" # версия чарта Bitnami PostgreSQL
  description = "Helm chart version for PostgreSQL"
}

variable "postgresql_password" {
  type        = string
  default     = "changeme" # ⚠️ для dev оставляем так, позже вынесем в Secret
  description = "PostgreSQL password for the postgres user"
}
