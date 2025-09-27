module "cluster_k3d" {
  source       = "../../modules/cluster-k3d"
  cluster_name = var.cluster_name
  servers      = 1
  agents       = 2
  http_port    = 80
  https_port   = 443
}

resource "helm_release" "ingress_nginx" {
  chart = "ingress-nginx"
  name  = "ingress-nginx"
  namespace = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"

  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
}

resource "helm_release" "cert_manager" {
  chart = "cert-manager"
  name  = "cert-manager"
  namespace = "cert-manager"
  repository = "https://charts.jetstack.io"

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "argocd" {
  chart = "argo-cd"
  name  = "argocd"
  namespace = "argocd"
  repository = "https://argoproj.github.io/argo-helm"

  create_namespace = true

  set {
    name  = "crds.install"
    value = "true"
  }
}
