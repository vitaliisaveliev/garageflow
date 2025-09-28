# 1) ingress-nginx
resource "helm_release" "ingress_nginx" {
  provider         = helm.local
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = var.ingress_nginx_version

  values = [ file("${path.module}/ingress-values.yaml") ]
}

# 2) cert-manager
resource "helm_release" "cert_manager" {
  provider         = helm.local
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = var.cert_manager_version

  values = [ yamlencode({ installCRDs = true }) ]
}

# 3) ArgoCD
resource "helm_release" "argocd" {
  provider         = helm.local
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_version

  values = [
    yamlencode({
      server = {
        service = { type = "ClusterIP" } # UI наружу через Ingress
      }
    })
  ]
}

# 4) Ingress для ArgoCD (бэкенд = HTTPS:443)
resource "kubernetes_ingress_v1" "argocd_ingress" {
  provider = kubernetes.local
  depends_on = [helm_release.argocd,  helm_release.ingress_nginx]

  metadata {
    name      = "argocd-server"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "false"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.argocd_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port { number = 443 }
            }
          }
        }
      }
    }
  }
}

