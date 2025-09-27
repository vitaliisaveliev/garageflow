#!/usr/bin/env bash
set -euo pipefail

echo "⚠️  WARNING: Hard reset of local dev environment starting..."
echo "Everything will be wiped: Terraform state, k3d clusters, Docker containers."

# 1. Убиваем все кластеры k3d
if command -v k3d &>/dev/null; then
  echo "🧹 Deleting all k3d clusters..."
  k3d cluster delete --all || true
else
  echo "⚠️ k3d not found, skipping..."
fi

# 2. Чистим контейнеры Docker, связанные с k3d
if command -v docker &>/dev/null; then
  echo "🧹 Cleaning up dangling k3d containers..."
  docker ps -a --filter "name=k3d-" -q | xargs -r docker rm -f
else
  echo "⚠️ Docker not found, skipping..."
fi

# 3. Чистим Terraform в dev-local
TF_DIR="iac/environments/dev-local"
if [ -d "$TF_DIR" ]; then
  echo "🧹 Cleaning Terraform caches and state in $TF_DIR ..."
  rm -rf "$TF_DIR/.terraform" \
         "$TF_DIR/.terraform.lock.hcl" \
         "$TF_DIR/terraform.tfstate" \
         "$TF_DIR/terraform.tfstate.backup" || true
else
  echo "⚠️ $TF_DIR not found, skipping..."
fi

# 4. (Опционально) Чистим kubeconfig от старых контекстов
if [ -f "$HOME/.kube/config" ]; then
  echo "🧹 Removing stale k3d contexts from kubeconfig..."
  for ctx in $(kubectl config get-contexts -o name | grep '^k3d-'); do
    kubectl config delete-context "$ctx" || true
    kubectl config delete-cluster "$ctx" || true
    kubectl config delete-user "admin@$ctx" || true
  done
else
  echo "⚠️ No kubeconfig found, skipping..."
fi

echo "✅ Hard reset complete! You can now run:"
echo "   cd iac/environments/dev-local && terraform init && terraform apply"
