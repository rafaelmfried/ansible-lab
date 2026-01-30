# 02 - Pré-requisitos e Preparação

**🏷️ Tags:** `#setup` `#prerequisites` `#environment`  
**📅 Criado:** Janeiro 2026  
**👤 Autor:** [@rafaelmfried](https://github.com/rafaelmfried)

---

## 🎯 Objetivo

Preparar seu ambiente de desenvolvimento com todas as ferramentas necessárias para executar o laboratório Ansible de forma segura e eficiente.

---

## 💻 Requisitos de Sistema

### **Sistema Operacional Suportado**

- **macOS** 12.0+ (Monterey ou superior)
- **Linux** (Ubuntu 20.04+, Debian 11+, CentOS 8+, Fedora 35+)
- **Windows** 11 com WSL2 (Ubuntu 22.04 recomendado)

### **Recursos Mínimos**

- **RAM**: 8 GB (16 GB recomendado)
- **Disco**: 20 GB livres
- **CPU**: 4 cores (8 cores recomendado)
- **Rede**: Conexão estável à internet

### **Recursos Recomendados para Performance**

- **RAM**: 16-32 GB
- **Disco**: SSD com 50+ GB livres
- **CPU**: 8+ cores
- **Rede**: Banda larga (para downloads de imagens Docker)

---

## 🛠️ Ferramentas Essenciais

### **1. Docker & Docker Compose**

#### **macOS (Homebrew)**

```bash
# Instalar Docker Desktop
brew install --cask docker

# Ou via download direto
# https://docs.docker.com/desktop/mac/install/

# Verificar instalação
docker --version
docker-compose --version
```

#### **Ubuntu/Debian**

```bash
# Atualizar repositórios
sudo apt update

# Instalar dependências
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Adicionar chave GPG oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adicionar repositório
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Relogar ou executar:
newgrp docker

# Verificar
docker --version
docker compose version
```

#### **CentOS/RHEL/Fedora**

```bash
# CentOS/RHEL
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Fedora
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Iniciar serviço
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Verificar
docker --version
docker compose version
```

#### **Windows (WSL2)**

```powershell
# 1. Instalar WSL2
wsl --install -d Ubuntu-22.04

# 2. Baixar Docker Desktop para Windows
# https://docs.docker.com/desktop/windows/install/

# 3. Habilitar integração com WSL2 no Docker Desktop
# Settings > Resources > WSL Integration

# 4. Dentro do WSL2:
docker --version
docker compose version
```

### **2. Ansible**

#### **Via pip (Recomendado)**

```bash
# Instalar pip se não estiver instalado
# Ubuntu/Debian
sudo apt install -y python3-pip

# CentOS/RHEL/Fedora
sudo yum install -y python3-pip  # ou dnf

# macOS
brew install python3

# Instalar Ansible
pip3 install ansible ansible-core

# Ou criar ambiente virtual (recomendado)
python3 -m venv ~/.ansible-venv
source ~/.ansible-venv/bin/activate
pip install ansible ansible-core

# Verificar
ansible --version
ansible-vault --version
```

#### **Via Package Manager**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y ansible

# macOS
brew install ansible

# CentOS/RHEL 8+
sudo dnf install -y ansible

# Fedora
sudo dnf install -y ansible
```

### **3. Git**

#### **Instalação**

```bash
# Ubuntu/Debian
sudo apt install -y git

# CentOS/RHEL/Fedora
sudo yum install -y git  # ou dnf

# macOS
brew install git
# Ou usar Xcode Command Line Tools
xcode-select --install
```

#### **Configuração Inicial**

```bash
# Configurar identidade
git config --global user.name "Seu Nome"
git config --global user.email "seu-email@exemplo.com"

# Configurar editor padrão
git config --global core.editor "vim"

# Verificar configuração
git config --list
```

### **4. Make (Build Tool)**

#### **Instalação**

```bash
# Ubuntu/Debian
sudo apt install -y make

# CentOS/RHEL/Fedora
sudo yum install -y make  # ou dnf

# macOS
xcode-select --install
# Ou via Homebrew
brew install make
```

### **5. Curl e Wget**

```bash
# Ubuntu/Debian
sudo apt install -y curl wget

# CentOS/RHEL/Fedora
sudo yum install -y curl wget  # ou dnf

# macOS (geralmente já incluídos)
brew install curl wget
```

---

## 🔑 Configuração do GitHub

### **1. Criar Conta GitHub**

Se ainda não tem uma conta:

1. Acesse [github.com](https://github.com)
2. Crie uma conta gratuita
3. Confirme seu e-mail

### **2. Configurar SSH Keys**

#### **Gerar Nova Chave SSH**

```bash
# Gerar chave SSH (substitua pelo seu e-mail)
ssh-keygen -t ed25519 -C "seu-email@exemplo.com"

# Ou para compatibilidade com sistemas antigos:
ssh-keygen -t rsa -b 4096 -C "seu-email@exemplo.com"

# Aceitar localização padrão (~/.ssh/id_ed25519)
# Definir passphrase (opcional mas recomendado)
```

#### **Adicionar ao SSH Agent**

```bash
# Iniciar ssh-agent
eval "$(ssh-agent -s)"

# Adicionar chave ao agent
ssh-add ~/.ssh/id_ed25519

# macOS: Adicionar ao Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

#### **Adicionar Chave ao GitHub**

```bash
# Copiar chave pública
cat ~/.ssh/id_ed25519.pub

# Ou no macOS:
pbcopy < ~/.ssh/id_ed25519.pub

# 1. Acessar GitHub.com → Settings → SSH and GPG keys
# 2. Clicar "New SSH key"
# 3. Dar um título descritivo
# 4. Colar a chave pública
# 5. Clicar "Add SSH key"
```

#### **Testar Conectividade SSH**

```bash
ssh -T git@github.com

# Resultado esperado:
# Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### **3. Configurar Acesso Público às Chaves**

Para que o laboratório possa acessar suas chaves SSH dinamicamente:

1. Acesse `https://github.com/SEU-USERNAME/keys`
2. Verifique se suas chaves estão visíveis
3. As chaves públicas são acessíveis em `https://github.com/SEU-USERNAME.keys`

---

## 🌐 Configuração de Rede

### **Verificar Conflitos de Rede**

#### **Verificar Redes Docker Existentes**

```bash
# Listar redes existentes
docker network ls

# Ver detalhes de redes
docker network inspect bridge

# Verificar se há conflito com 198.18.100.0/24
ip route | grep 198.18 || echo "✅ Rede disponível"
```

#### **Verificar Conflitos VPN/Corporativos**

```bash
# Verificar rotas ativas
ip route show

# Verificar interfaces de rede
ip addr show

# Verificar se há VPN ativa que pode conflitar
ps aux | grep -i vpn
```

### **Configurar Firewall (Se Necessário)**

#### **Ubuntu/Debian (UFW)**

```bash
# Verificar status
sudo ufw status

# Permitir Docker (se firewall estiver ativo)
sudo ufw allow 2376/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 8082/tcp
```

#### **CentOS/RHEL/Fedora (Firewalld)**

```bash
# Verificar status
sudo firewall-cmd --state

# Adicionar regras se necessário
sudo firewall-cmd --permanent --add-service=docker
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --permanent --add-port=8082/tcp
sudo firewall-cmd --reload
```

#### **macOS (pfctl)**

```bash
# macOS geralmente não requer configuração adicional
# Docker Desktop cuida das regras de rede automaticamente
```

---

## 📁 Estrutura de Diretórios

### **Criar Workspace**

```bash
# Criar diretório de trabalho
mkdir -p ~/workspace/ansible-lab
cd ~/workspace/ansible-lab

# Verificar permissões
ls -la
pwd
```

### **Clonar Repositório**

```bash
# Clonar seu fork do laboratório
git clone git@github.com:SEU-USERNAME/ansible-lab.git
cd ansible-lab

# Ou clonar o original e fazer fork depois
git clone https://github.com/rafaelmfried/ansible-lab.git
cd ansible-lab
```

---

## ✅ Verificação de Ambiente

### **Executar Verificação**

```bash
# Tornar executável e rodar
chmod +x scripts/check_prerequisites.sh
./scripts/check_prerequisites.sh
```

---

## 🚨 Solução de Problemas Comuns

### **Docker não inicia**

```bash
# Linux: Iniciar serviço Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verificar logs
sudo journalctl -u docker

# macOS: Reiniciar Docker Desktop
# Quit Docker Desktop e reabrir

# Windows: Reiniciar WSL2
wsl --shutdown
# Reiniciar Docker Desktop
```

### **Permission denied (Docker)**

```bash
# Adicionar usuário ao grupo docker (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Ou logout/login novamente
```

### **Ansible não encontrado**

```bash
# Verificar PATH
echo $PATH

# Reinstalar com user install
pip3 install --user ansible

# Adicionar ao PATH (Linux/macOS)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### **GitHub SSH falha**

```bash
# Verificar se chave existe
ls -la ~/.ssh/

# Regenerar chave se necessário
ssh-keygen -t ed25519 -C "seu-email@exemplo.com"

# Testar conexão com debug
ssh -vT git@github.com
```

---

## 🔗 Próximos Passos

1. **[03-setup-lab](03-setup-lab.md)** - Setup inicial do laboratório
2. **[04-conceitos-vault](04-conceitos-vault.md)** - Entender Ansible Vault
3. **[06-configuracao-vault](06-configuracao-vault.md)** - Configurar segurança

---

## 📚 Recursos Adicionais

### **Documentação Oficial**

- [Docker Install](https://docs.docker.com/get-docker/)
- [Ansible Installation](https://docs.ansible.com/ansible/latest/installation_guide/)
- [GitHub SSH Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

### **Tutoriais de Apoio**

- [Docker Tutorial](https://www.docker.com/101-tutorial)
- [Ansible Basics](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html)
- [Git Basics](https://git-scm.com/doc)

---

**Próximo:** Agora que seu ambiente está preparado, vamos fazer o [setup inicial do laboratório](03-setup-lab.md)!
