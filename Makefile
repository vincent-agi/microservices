# Makefile pour la gestion des microservices
.PHONY: help start stop restart status logs build clean

# Couleurs pour l'affichage
GREEN=\033[0;32m
YELLOW=\033[1;33m
RED=\033[0;31m
NC=\033[0m # No Color

help: ## Affiche cette aide
	@echo "$(GREEN)🔧 Gestion des Microservices$(NC)"
	@echo ""
	@echo "$(YELLOW)Commandes disponibles:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-12s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)URLs d'accès après démarrage:$(NC)"
	@echo "  - UserService API:    http://localhost:3000"
	@echo "  - CartService API:    http://localhost:5001"
	@echo "  - OrderService API:   http://localhost:8080"
	@echo "  - User DB Admin:      http://localhost:8083"
	@echo "  - Cart DB Admin:      http://localhost:8082"
	@echo "  - Order DB Admin:     http://localhost:8084"

start: ## Démarre tous les microservices
	@echo "$(GREEN)🚀 Démarrage de tous les microservices...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)✅ Tous les services sont démarrés!$(NC)"

stop: ## Arrête tous les microservices
	@echo "$(YELLOW)🛑 Arrêt de tous les microservices...$(NC)"
	docker-compose down
	@echo "$(GREEN)✅ Tous les services sont arrêtés!$(NC)"

restart: stop start ## Redémarre tous les microservices

status: ## Affiche l'état de tous les services
	@echo "$(YELLOW)📊 État des microservices:$(NC)"
	docker-compose ps

logs: ## Affiche les logs de tous les services
	@echo "$(YELLOW)📋 Logs de tous les services:$(NC)"
	docker-compose logs -f

build: ## Reconstruit toutes les images Docker
	@echo "$(YELLOW)🔨 Reconstruction des images Docker...$(NC)"
	docker-compose build --no-cache
	@echo "$(GREEN)✅ Images reconstruites!$(NC)"

clean: ## Nettoyage complet (conteneurs + volumes)
	@echo "$(RED)🧹 Nettoyage complet...$(NC)"
	docker-compose down -v --remove-orphans
	docker system prune -f
	@echo "$(GREEN)✅ Nettoyage terminé!$(NC)"

# Commandes spécifiques par service
user-logs: ## Affiche les logs du UserService
	docker-compose logs -f user-api

cart-logs: ## Affiche les logs du CartService
	docker-compose logs -f cart-api

order-logs: ## Affiche les logs de l'OrderService
	docker-compose logs -f order-api