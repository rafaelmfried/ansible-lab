# ===== VARIABLES =====
DOCKERFILE_NODE := docker/Dockerfile.ansible-node
DOCKERFILE_CONTROL := docker/Dockerfile.ansible-control
DOCKERFILE_VM := docker/Dockerfile.vm
DOCKER_COMPOSE := compose.yaml

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[0;37m
NC := \033[0m # No Color

# ===== PHONY TARGETS =====
.PHONY: help lab up down build clean status logs shell test-connectivity setup-ssh

# ===== DEFAULT TARGET =====
help: ## 🆘 Show this help message
	@echo "$(CYAN)🔧 Ansible Lab Management$(NC)"
	@echo ""
	@echo "$(GREEN)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ===== LAB MANAGEMENT =====
lab: up ## 🚀 Alias for 'make up' - Start the lab

up: ## 🚀 Start the Ansible lab environment
	@echo "$(GREEN)🚀 Starting Ansible Lab...$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✅ Lab started successfully!$(NC)"
	@echo ""
	@echo "$(CYAN)📋 Container Status:$(NC)"
	@make status
	@echo ""
	@echo "$(YELLOW)🔑 Setting up SSH keys... (wait 10 seconds)$(NC)"
	@sleep 10
	@make setup-ssh
	@echo ""
	@echo "$(GREEN)🎉 Lab is ready! Use 'make shell' to enter the control node$(NC)"

down: ## 🛑 Stop the Ansible lab environment
	@echo "$(RED)🛑 Stopping Ansible Lab...$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) down
	@echo "$(RED)✅ Lab stopped successfully!$(NC)"

# ===== BUILD TARGETS =====
build: ## 🔨 Build all Docker images
	@echo "$(BLUE)🔨 Building Docker images...$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)✅ Images built successfully!$(NC)"

build-control: ## 🔨 Build only control node image
	@echo "$(BLUE)🔨 Building control node image...$(NC)"
	@docker build -f $(DOCKERFILE_CONTROL) -t ansible-lab-control .
	@echo "$(GREEN)✅ Control node image built!$(NC)"

build-nodes: ## 🔨 Build only managed nodes image
	@echo "$(BLUE)🔨 Building managed nodes image...$(NC)"
	@docker build -f $(DOCKERFILE_NODE) -t ansible-lab-node .
	@echo "$(GREEN)✅ Managed nodes image built!$(NC)"

build-vm: ## 🔨 Build only VM host image
	@echo "$(BLUE)🔨 Building VM host image...$(NC)"
	@docker build -f $(DOCKERFILE_VM) -t ansible-lab-vm .
	@echo "$(GREEN)✅ VM host image built!$(NC)"

# ===== MANAGEMENT TARGETS =====
status: ## 📊 Show lab containers status
	@echo "$(CYAN)📊 Lab Status:$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) ps

logs: ## 📝 Show logs from all containers
	@echo "$(CYAN)📝 Container Logs:$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) logs -f

logs-control: ## 📝 Show logs from control node
	@docker compose -f $(DOCKER_COMPOSE) logs -f ansible-control

shell: ## 🐚 Enter the Ansible control node shell
	@echo "$(CYAN)🐚 Entering Ansible control node...$(NC)"
	@docker exec -it ansible-control /bin/bash

# ===== VAULT OPERATIONS =====
setup-vault: ## 🔐 Configure SSH keys using Ansible Vault
	@echo "$(YELLOW)🔐 Configuring SSH keys via Vault...$(NC)"
	@docker exec ansible-control ansible-playbook playbooks/setup-ssh-vault.yml
	@echo "$(GREEN)✅ Vault SSH keys configured!$(NC)"

edit-vault: ## ✏️ Edit vault file
	@echo "$(YELLOW)✏️ Editing vault file...$(NC)"
	@docker exec -it ansible-control ansible-vault edit group_vars/all/vault.yml

view-vault: ## 👁️ View vault contents
	@echo "$(CYAN)👁️ Vault contents:$(NC)"
	@docker exec ansible-control ansible-vault view group_vars/all/vault.yml

test-vault: ## 🧪 Test vault variables
	@echo "$(YELLOW)🧪 Testing vault variables...$(NC)"
	@docker exec ansible-control ansible all -m debug -a "var=ssh_public_key"
setup-ssh: setup-vault ## 🔑 Setup SSH keys between control and managed nodes (via Vault)
	@echo "$(YELLOW)🔑 Setting up SSH keys...$(NC)"
	@docker exec ansible-control bash -c " \
		for host in web-server-1 web-server-2 db-server-1 app-server-1 vm-host; do \
			echo \"Setting up SSH for \$$host...\"; \
			sshpass -p 'ansible' ssh-copy-id -o StrictHostKeyChecking=no ansible@\$$host 2>/dev/null || true; \
		done \
	"
	@echo "$(GREEN)✅ SSH keys configured!$(NC)"

# ===== TESTING =====
test-connectivity: ## 🔍 Test Ansible connectivity to all hosts
	@echo "$(YELLOW)🔍 Testing Ansible connectivity...$(NC)"
	@docker exec ansible-control ansible all -m ping -i inventory/lab.ini || echo "$(RED)❌ Create inventory first!$(NC)"

test-inventory: ## 📋 Test and display inventory
	@echo "$(YELLOW)📋 Testing inventory...$(NC)"
	@docker exec ansible-control ansible-inventory --list -i inventory/lab.ini || echo "$(RED)❌ Create inventory first!$(NC)"

# ===== CLEANUP =====
clean: down ## 🧹 Clean up containers and images
	@echo "$(RED)🧹 Cleaning up...$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) down -v --remove-orphans
	@docker system prune -f
	@echo "$(GREEN)✅ Cleanup completed!$(NC)"

clean-all: clean ## 🧹💥 Clean everything including images and volumes
	@echo "$(RED)🧹💥 Deep cleaning...$(NC)"
	@docker compose -f $(DOCKER_COMPOSE) down -v --remove-orphans --rmi all
	@docker volume prune -f
	@echo "$(GREEN)✅ Deep cleanup completed!$(NC)"

# ===== DEVELOPMENT =====
restart: down up ## 🔄 Restart the lab environment

rebuild: clean build up ## 🔄 Rebuild and restart everything

# ===== INFO =====
info: ## ℹ️  Show lab information
	@echo "$(CYAN)ℹ️  Ansible Lab Information$(NC)"
	@echo ""
	@echo "$(YELLOW)🌐 Network:$(NC) ansible_lab (198.18.100.0/24 - RFC 2544 Benchmarking)"
	@echo "$(YELLOW)📦 Containers:$(NC)"
	@echo "  • ansible-control (198.18.100.10:2222) - Control Node"
	@echo "  • web-server-1 (198.18.100.20:2220) - Web Server 1"
	@echo "  • web-server-2 (198.18.100.21:2221) - Web Server 2"
	@echo "  • db-server-1 (198.18.100.30:2230) - Database Server"
	@echo "  • app-server-1 (198.18.100.40:2240) - Application Server"
	@echo "  • vm-host (198.18.100.50:2250) - VM Host"
	@echo ""
	@echo "$(YELLOW)🔑 Credentials:$(NC)"
	@echo "  • Username: ansible"
	@echo "  • Password: ansible"
	@echo "  • SSH Key: rafaelmfried (GitHub - managed via Vault)"
	@echo ""
	@echo "$(YELLOW)📝 Quick Start:$(NC)"
	@echo "  1. make lab      # Start everything"
	@echo "  2. make shell    # Enter control node"
	@echo "  3. ansible all -m ping  # Test connectivity"
	@echo ""
	@echo "$(YELLOW)🔌 External SSH Access:$(NC)"
	@echo "  ssh ansible@localhost -p 2222  # Control node"
	@echo "  ssh ansible@localhost -p 2220  # Web server 1"
	@echo ""
	@echo "$(YELLOW)🔐 Vault Commands:$(NC)"
	@echo "  make setup-vault    # Configure SSH via Vault"
	@echo "  make edit-vault     # Edit vault secrets"
	@echo "  make view-vault     # View vault contents"

# ===== VERSION =====
version: ## 📋 Show versions of tools
	@echo "$(CYAN)📋 Tool Versions:$(NC)"
	@docker --version
	@docker compose version
	@echo ""
	@echo "$(YELLOW)Ansible version in control node:$(NC)"
	@docker exec ansible-control ansible --version 2>/dev/null || echo "Container not running"