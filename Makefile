# ===== VARIABLES =====
DOCKER_COMPOSE := compose.yaml
CONTROL_CONTAINER := ansible-control
INVENTORY := inventory/basic-hosts

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
NC := \033[0m # No Color

# ===== PHONY TARGETS =====
.PHONY: lab help up down build status logs shell setup-ssh setup-vault test-connectivity clean

# ===== DEFAULT TARGET =====
help: ## Show this help message
	@echo "$(CYAN)🔧 Ansible Lab Management$(NC)"
	@echo ""
	@echo "$(GREEN)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ===== LAB MANAGEMENT =====
lab: up ## Start the Ansible lab environment (default)

up: ## Start the Ansible lab environment
	@echo "$(GREEN)🚀 Starting Ansible Lab...$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✅ Lab started successfully!$(NC)"
	@echo ""
	@echo "$(CYAN)📋 Container Status:$(NC)"
	@$(MAKE) status
	@echo ""
	@echo "$(YELLOW)🔑 Setting up SSH keys... (wait 10 seconds)$(NC)"
	@sleep 10
	@$(MAKE) setup-ssh
	@echo ""
	@echo "$(GREEN)🎉 Lab is ready! Use 'make shell' to enter the control node$(NC)"

down: ## Stop the Ansible lab environment
	@echo "$(RED)🛑 Stopping Ansible Lab...$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) down
	@echo "$(RED)✅ Lab stopped successfully!$(NC)"

# ===== BUILD =====
build: ## Build all Docker images
	@echo "$(BLUE)🔨 Building Docker images...$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)✅ Images built successfully!$(NC)"

# ===== MANAGEMENT =====
status: ## Show lab containers status
	@echo "$(CYAN)📊 Lab Status:$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) ps

logs: ## Show logs from all containers
	@echo "$(CYAN)📝 Container Logs:$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) logs -f

shell: ## Enter the Ansible control node shell
	@echo "$(CYAN)🐚 Entering Ansible control node...$(NC)"
	@docker exec -it $(CONTROL_CONTAINER) /bin/bash

# ===== VAULT OPERATIONS =====
setup-vault: ## Configure SSH keys using Ansible Vault
	@echo "$(YELLOW)🔐 Configuring SSH keys via Vault...$(NC)"
	@docker exec $(CONTROL_CONTAINER) bash -c "echo 'ansible-lab-2026' > /home/ansible/.vault_pass && chmod 600 /home/ansible/.vault_pass"
	@docker exec $(CONTROL_CONTAINER) ansible-playbook -i $(INVENTORY) playbooks/setup-ssh-vault.yaml --vault-password-file=/home/ansible/.vault_pass
	@echo "$(GREEN)✅ Vault SSH keys configured!$(NC)"

# ===== SSH =====
setup-ssh: ## Setup SSH keys between control and managed nodes
	@echo "$(YELLOW)🔑 Setting up SSH keys...$(NC)"
	@docker exec $(CONTROL_CONTAINER) bash -c " \
		for host in vm1 vm2 vm3 vm4 vm5; do \
			echo \"Setting up SSH for \$$host...\"; \
			sshpass -p 'ansible' ssh-copy-id -o StrictHostKeyChecking=no ansible@\$$host 2>/dev/null || true; \
		done \
	"
	@echo "$(GREEN)✅ SSH keys configured!$(NC)"

# ===== TESTING =====
test-connectivity: ## Test Ansible connectivity to all hosts
	@echo "$(YELLOW)🔍 Testing Ansible connectivity...$(NC)"
	@docker exec $(CONTROL_CONTAINER) ansible all -m ping -i $(INVENTORY) || \
		echo "$(RED)❌ Start the lab first and check $(INVENTORY)$(NC)"

# ===== CLEANUP =====
clean: ## Clean up containers and images
	@echo "$(RED)🧹 Cleaning up...$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) down -v --remove-orphans
	@docker system prune -f
	@echo "$(GREEN)✅ Cleanup completed!$(NC)"
