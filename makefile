# Корневой Makefile для управления локальной инфраструктурой

CLUSTER_DIR=iac/environments/dev-local/cluster
PLATFORM_DIR=iac/environments/dev-local/platform

.PHONY: up down reset cluster-up cluster-down platform-up platform-down argocd-password

## Поднять кластер и платформу
up: cluster-up platform-up
	@echo "✅ Кластер и платформа подняты"

# Вспомогательная функция: проверка готовности кластера
define wait_for_cluster
  echo "⏳ Waiting for Kubernetes API..."
  until kubectl cluster-info &>/dev/null; do \
    echo "   ... still waiting"; \
    sleep 5; \
  done; \
  echo "✅ API is reachable"

  echo "⏳ Waiting for nodes to be Ready..."
  kubectl wait --for=condition=Ready nodes --all --timeout=120s
  echo "✅ All nodes are Ready"
endef

.PHONY: up down reset cluster platform

## 🚀 Полный запуск: кластер + платформа
up: cluster platform

## 🔥 Полное удаление: сначала платформа, потом кластер
down:
	@echo "🔥 Destroying platform..."
	cd $(PLATFORM_DIR) && terraform destroy -auto-approve || true
	@echo "🔥 Destroying cluster..."
	cd $(CLUSTER_DIR) && terraform destroy -auto-approve || true

## ♻️ Полный ресет стейтов и кешей
reset:
	@echo "🧹 Resetting Terraform states and caches..."
	find . -type d -name ".terraform" -exec rm -rf {} +
	find . -type f -name "terraform.tfstate*" -delete
	@echo "✅ All Terraform states and caches have been removed."

## ⚙️ Поднять кластер
cluster:
	@echo "🚀 Applying cluster..."
	cd $(CLUSTER_DIR) && terraform init -upgrade && terraform apply -auto-approve
	@$(call wait_for_cluster)

## ⚙️ Поднять платформу (только если кластер уже готов)
platform:
	@echo "🚀 Applying platform..."
	cd $(PLATFORM_DIR) && terraform init -upgrade && terraform apply -auto-approve

## Показать креды для ArgoCD
argocd-password:
	@echo "🔑 ArgoCD URL: https://argocd.localhost"
	@echo "👤 Username: admin"
	@echo -n "🔒 Password: "
	@kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" | base64 -d; echo

bootstrap-apps:
	@echo "⏳ Ждём готовности ArgoCD server..."
	@kubectl -n argocd rollout status deploy/argocd-server --timeout=180s
	@echo "🚀 Применяем root Application (apps.yaml)..."
	kubectl -n argocd apply -f gitops/bootstrap/apps.yaml
	@echo "✅ Bootstrap завершён. Проверяем приложения..."
	kubectl -n argocd get applications
