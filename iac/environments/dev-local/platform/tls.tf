resource "null_resource" "selfsigned_clusterissuer" {
  depends_on = [helm_release.cert_manager]

  provisioner "local-exec" {
    command = <<EOT
      echo "⏳ Waiting for cert-manager CRDs..."
      until kubectl get crd clusterissuers.cert-manager.io >/dev/null 2>&1; do
        echo "   ... still waiting"
        sleep 3
      done
      echo "✅ CRDs are ready"

      echo "🚀 Applying selfsigned ClusterIssuer..."
      kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
