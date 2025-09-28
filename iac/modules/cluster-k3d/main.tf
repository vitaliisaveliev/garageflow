terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

resource "null_resource" "k3d_cluster" {
  triggers = {
    cluster_name = var.cluster_name
    servers      = var.servers
    agents       = var.agents
    http_port    = var.http_port
    https_port   = var.https_port
  }

  provisioner "local-exec" {
    command = <<EOT
set -euo pipefail

if ! k3d cluster list | awk '{print $1}' | grep -qx "${self.triggers.cluster_name}"; then
  echo "🚀 Creating k3d cluster '${self.triggers.cluster_name}'..."
  k3d cluster create ${self.triggers.cluster_name} \
    --servers ${self.triggers.servers} --agents ${self.triggers.agents} \
    --port ${self.triggers.http_port}:80@loadbalancer \
    --port ${self.triggers.https_port}:443@loadbalancer \
    --k3s-arg "--disable=traefik@server:0" \
    --wait

  echo "🔧 Merging kubeconfig & switching context..."
  k3d kubeconfig merge ${self.triggers.cluster_name} --kubeconfig-merge-default --kubeconfig-switch-context

  echo "⏳ Waiting for Kubernetes API..."
  until kubectl cluster-info &>/dev/null; do
    echo "   ... still waiting"
    sleep 5
  done
  echo "✅ API is reachable"

  echo "⏳ Waiting for nodes to be Ready..."
  kubectl wait --for=condition=Ready nodes --all --timeout=120s
  echo "✅ All nodes are Ready"
else
  echo "ℹ️ Cluster '${self.triggers.cluster_name}' already exists, skipping create."
fi
EOT
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
set -euo pipefail
if k3d cluster list | awk '{print $1}' | grep -qx "${self.triggers.cluster_name}"; then
  echo "🔥 Deleting cluster '${self.triggers.cluster_name}'..."
  k3d cluster delete ${self.triggers.cluster_name}
else
  echo "ℹ️ Cluster '${self.triggers.cluster_name}' not found, nothing to delete."
fi
EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
