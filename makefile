# Корневой Makefile для управления локальной инфраструктурой

CLUSTER_DIR=iac/environments/dev-local/cluster
PLATFORM_DIR=iac/environments/dev-local/platform

.PHONY: up down reset cluster-up cluster-down platform-up platform-down argocd-password

## Поднять кластер и платформу
up: cluster-up platform-up
	@echo "✅ Кластер и платформа подняты"

## Снести кластер и платформу
down: platform-down cluster-down
	@echo "🧹 Кластер и платформа удалены"

## Полный reset (сначала destroy, потом apply заново)
reset: down up

## Только кластер
cluster-up:
	cd $(CLUSTER_DIR) && terraform init && terraform apply -auto-approve

cluster-down:
	cd $(CLUSTER_DIR) && terraform destroy -auto-approve || true

## Только платформа (ингресс, cert-manager, argoCD)
platform-up:
	cd $(PLATFORM_DIR) && terraform init && terraform apply -auto-approve

platform-down:
	cd $(PLATFORM_DIR) && terraform destroy -auto-approve || true

## Показать креды для ArgoCD
argocd-password:
	@echo "🔑 ArgoCD URL: https://argocd.localhost:8444"
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
