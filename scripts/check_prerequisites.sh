#!/bin/bash
# check_prerequisites.sh

echo "🔍 Verificando Pré-requisitos do Ansible Lab"
echo "=============================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_tool() {
    local tool=$1
    local version_cmd=$2
    local min_version=$3
    
    if command -v $tool &> /dev/null; then
        version=$($version_cmd 2>&1 | head -1)
        echo -e "✅ ${GREEN}$tool${NC}: $version"
        return 0
    else
        echo -e "❌ ${RED}$tool${NC}: Não encontrado"
        return 1
    fi
}

check_port() {
    local port=$1
    if lsof -i:$port &> /dev/null; then
        echo -e "⚠️  ${YELLOW}Porta $port${NC}: Em uso"
        return 1
    else
        echo -e "✅ ${GREEN}Porta $port${NC}: Disponível"
        return 0
    fi
}

failed=0

# Verificar ferramentas essenciais
echo "🛠️  Ferramentas Essenciais:"
check_tool "docker" "docker --version" || failed=$((failed + 1))
check_tool "docker-compose" "docker-compose --version" || check_tool "docker" "docker compose version" || failed=$((failed + 1))
check_tool "ansible" "ansible --version" || failed=$((failed + 1))
check_tool "ansible-vault" "ansible-vault --version" || failed=$((failed + 1))
check_tool "git" "git --version" || failed=$((failed + 1))
check_tool "make" "make --version" || failed=$((failed + 1))
check_tool "curl" "curl --version" || failed=$((failed + 1))

echo ""

# Verificar serviços
echo "🔄 Serviços:"
if systemctl is-active --quiet docker 2>/dev/null || pgrep -x "Docker Desktop" > /dev/null; then
    echo -e "✅ ${GREEN}Docker${NC}: Rodando"
else
    echo -e "❌ ${RED}Docker${NC}: Não está rodando"
    failed=$((failed + 1))
fi

echo ""

# Verificar portas
echo "🌐 Portas:"
check_port 8081
check_port 8082
check_port 3000

echo ""

# Verificar conectividade GitHub
echo "🔗 Conectividade:"
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo -e "✅ ${GREEN}GitHub SSH${NC}: Configurado"
else
    echo -e "⚠️  ${YELLOW}GitHub SSH${NC}: Não configurado ou inacessível"
fi

if curl -s https://api.github.com/zen &> /dev/null; then
    echo -e "✅ ${GREEN}GitHub API${NC}: Acessível"
else
    echo -e "❌ ${RED}GitHub API${NC}: Inacessível"
    failed=$((failed + 1))
fi

echo ""

# Verificar recursos do sistema
echo "💻 Recursos do Sistema:"
# RAM
total_ram=$(free -m 2>/dev/null | grep Mem | awk '{print $2}' || sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024}')
if [ "$total_ram" -gt 7000 ]; then
    echo -e "✅ ${GREEN}RAM${NC}: ${total_ram}MB (Adequado)"
else
    echo -e "⚠️  ${YELLOW}RAM${NC}: ${total_ram}MB (Mínimo 8GB recomendado)"
fi

# Disco
available_space=$(df -BG . | tail -1 | awk '{print $4}' | tr -d 'G')
if [ "$available_space" -gt 20 ]; then
    echo -e "✅ ${GREEN}Disco${NC}: ${available_space}GB disponível"
else
    echo -e "⚠️  ${YELLOW}Disco${NC}: ${available_space}GB (Mínimo 20GB recomendado)"
fi

echo ""
echo "=============================================="

if [ $failed -eq 0 ]; then
    echo -e "🎉 ${GREEN}Ambiente pronto para o Ansible Lab!${NC}"
    exit 0
else
    echo -e "💥 ${RED}$failed verificação(ões) falharam. Instale as ferramentas necessárias.${NC}"
    exit 1
fi