terraform {
  required_version = ">= 1.6.0"
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
  echo "Creating k3d cluster '${self.triggers.cluster_name}'..."
  k3d cluster create ${self.triggers.cluster_name} \
  --servers ${self.triggers.servers} --agents ${self.triggers.agents} \
  --port ${self.triggers.http_port}:80@loadbalancer \
  --port ${self.triggers.https_port}:443@loadbalancer \
  --k3s-arg "--disable=traefik@server:0" \
  --wait

else
  echo "k3d cluster '${self.triggers.cluster_name}' already exists, skipping create."
fi
EOT
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
set -euo pipefail
if k3d cluster list | awk '{print $1}' | grep -qx "${self.triggers.cluster_name}"; then
  echo "Deleting k3d cluster '${self.triggers.cluster_name}'..."
  k3d cluster delete ${self.triggers.cluster_name}
else
  echo "k3d cluster '${self.triggers.cluster_name}' not found, nothing to delete."
fi
EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
