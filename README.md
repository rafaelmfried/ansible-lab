# 🚀 Estudos de Ansible - Lab Completo

> **Ambiente Docker profissional para aprendizado prático de Ansible**  
> Baseado em **Debian 13 (Trixie)** com automação completa via Makefile

Este repositório contém um laboratório completo e isolado para estudar Ansible, simulando uma infraestrutura real com múltiplos servidores em containers Docker.

## 🎯 Objetivo

Fornecer um ambiente seguro, reproduzível e completo para:

- ✅ **Aprender Ansible** do básico ao avançado
- ✅ **Praticar playbooks** e roles em ambiente real
- ✅ **Testar configurações** sem impacto em sistemas reais
- ✅ **Simular cenários** de infraestrutura complexa
- ✅ **Desenvolver skills** de automação e DevOps

## 🏗️ Arquitetura do Lab

```
🌐 Rede Isolada: 198.18.100.0/24 (RFC 2544)

📊 Control Node     🌐 Web Servers      🗄️ Database        🚀 App Server     💻 VM Host
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌───────────────┐ ┌─────────────────┐
│ ansible-control │ │ web-server-1    │ │ db-server-1     │ │ app-server-1  │ │ vm-host         │
│ 198.18.100.10   │ │ 198.18.100.20   │ │ 198.18.100.30   │ │ 198.18.100.40 │ │ 198.18.100.50   │
│ :2222          │ │ :2220           │ │ :2230           │ │ :2240         │ │ :2250           │
└─────────────────┘ │ web-server-2    │ └─────────────────┘ └───────────────┘ └─────────────────┘
                     │ 198.18.100.21   │
                     │ :2221           │
                     └─────────────────┘
```

## 🛠️ Tecnologias e Features

- **🐧 OS**: Debian 13 (Trixie) - Latest stable
- **🐍 Python**: 3.13 com Ansible latest version
- **🔧 Automação**: Makefile completo para todas as operações
- **🌐 Networking**: Rede isolada com IPs fixos
- **🔑 SSH**: Chaves pré-configuradas e acesso externo
- **💾 Storage**: Volumes persistentes para dados
- **🏥 Health**: Health checks e monitoring
- **🔒 Security**: Usuários não-root e privilege escalation

## 🚀 Quick Start

### 1. **Pré-requisitos**

```bash
# Verificar dependências
docker --version          # ≥ 20.10
docker compose version    # ≥ 2.0
make --version           # GNU Make
```

### 2. **Iniciar o Lab**

```bash
# Comando único - faz tudo!
make lab

# Ou ver todas as opções
make help
```

### 3. **Verificar Status**

```bash
make status    # Ver containers rodando
make info      # Informações completas
```

### 4. **Entrar e Testar**

```bash
# Entrar no control node
make shell

# Dentro do container
ansible all -m ping                    # Testar conectividade
ansible all -m setup                   # Coletar facts
ansible webservers -m shell -a "uptime" # Executar comandos
```

## 📚 Conteúdo de Estudo

### 🎓 **Níveis de Aprendizado**

1. **🟢 Básico** - Conectividade e módulos ad-hoc
2. **🟡 Intermediário** - Playbooks e inventários
3. **🟠 Avançado** - Roles, templates e handlers
4. **🔴 Expert** - Vault, testing e CI/CD
5. **🟣 Master** - Cloud provisioning e scaling

### 📂 **Estrutura do Projeto**

```
ansible/
├── 🐳 docker/              # Dockerfiles personalizados
│   ├── Dockerfile.ansible-control  # Control node
│   ├── Dockerfile.ansible-node     # Managed nodes
│   └── Dockerfile.vm              # VM simulation
├── 📋 inventory/           # Inventários de hosts
│   └── lab.ini            # Inventário principal
├── 📜 playbooks/          # Playbooks de exemplo
│   ├── site.yml           # Playbook principal
│   ├── webservers.yml     # Configuração web
│   └── databases.yml      # Configuração DB
├── 🎭 roles/              # Roles reutilizáveis
│   ├── common/            # Configurações básicas
│   ├── nginx/             # Web server
│   └── mysql/             # Database
├── 🌍 group_vars/         # Variáveis por grupo
├── 🏠 host_vars/          # Variáveis por host
├── 📦 collections/        # Ansible Collections
├── 🐳 compose.yaml        # Docker Compose config
├── ⚙️ ansible.cfg         # Configuração Ansible
├── 🔧 Makefile           # Automação completa
└── 📖 docs/              # Documentação
    └── setup_lab.md      # Setup detalhado
```

## 🔧 Comandos Make Principais

```bash
# 🏃‍♂️ Operações Básicas
make lab           # Iniciar lab completo
make down          # Parar lab
make restart       # Reiniciar
make status        # Ver status
make shell         # Entrar no control node

# 🔨 Build e Deploy
make build         # Construir todas as images
make rebuild       # Rebuild completo
make clean         # Limpeza básica
make clean-all     # Limpeza completa

# 🔍 Debug e Testes
make logs          # Ver todos os logs
make test-connectivity  # Testar Ansible
make setup-ssh     # Reconfigurar SSH

# ℹ️ Informações
make info          # Informações do lab
make version       # Versões das tools
make help          # Todos os comandos
```

## 🎯 Exercícios Práticos

### **Exercício 1**: Conectividade Básica

```bash
make shell
ansible all -m ping
ansible all -m setup --limit web-server-1
```

### **Exercício 2**: Instalação de Pacotes

```bash
ansible webservers -m apt -a "name=nginx state=present" -b
ansible webservers -m service -a "name=nginx state=started enabled=yes" -b
```

### **Exercício 3**: Criação de Playbook

```yaml
# playbooks/primeiro-playbook.yml
---
- name: Configurar servidores web
  hosts: webservers
  become: yes
  tasks:
    - name: Instalar Nginx
      apt:
        name: nginx
        state: latest
        update_cache: yes

    - name: Iniciar serviço
      systemd:
        name: nginx
        state: started
        enabled: yes
```

### **Exercício 4**: Templates e Variáveis

```bash
# Criar template Jinja2
vim roles/nginx/templates/index.html.j2

# Usar no playbook
- name: Deploy custom index
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
```

## 🔐 Acesso e Credenciais

### **SSH Direto aos Containers**

```bash
ssh ansible@localhost -p 2222  # Control node
ssh ansible@localhost -p 2220  # Web server 1
ssh ansible@localhost -p 2230  # Database server
ssh ansible@localhost -p 2240  # App server
ssh ansible@localhost -p 2250  # VM host
```

### **Credenciais Padrão**

- **👤 Usuário**: `ansible`
- **🔑 Password**: `ansible`
- **🗝️ SSH Key**: `rafael.friederick@gmail.com` (pré-configurada)
- **🛡️ Sudo**: NOPASSWD habilitado

## 🌟 Features Avançadas

### **🖥️ Virtualização** (vm-host)

- **QEMU/KVM** para criar VMs reais
- **Cloud-init** para provisionamento
- **VNC** access via `localhost:5920-5930`
- **libvirt** para gerenciamento

### **💾 Persistência**

- **SSH Keys**: Compartilhadas entre containers
- **Database**: Volume persistente MySQL
- **VM Storage**: Imagens e VMs salvas
- **Logs**: Centralizados via Docker

### **🔍 Monitoring**

- **Health Checks**: SSH services
- **Resource Usage**: `make status`
- **Container Logs**: `make logs`
- **Network Debug**: Ferramentas incluídas

## 🚨 Troubleshooting

### **Problema**: Conflito de rede

```bash
docker network prune -f
make clean && make lab
```

### **Problema**: SSH não conecta

```bash
make setup-ssh
ssh -vvv ansible@localhost -p 2222
```

### **Problema**: Container não inicia

```bash
make logs
docker logs ansible-control
make rebuild
```

### **Problema**: Porta em uso

```bash
lsof -i :2222
make down
make clean
make lab
```

## 🎓 Recursos de Aprendizado

### **📖 Documentação**

- [Setup Lab Detalhado](docs/setup_lab.md)
- [Ansible Official Docs](https://docs.ansible.com/)
- [Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

### **🎮 Labs Práticos**

- **Lab 1**: Conectividade e inventários
- **Lab 2**: Playbooks básicos
- **Lab 3**: Roles e templates
- **Lab 4**: Handlers e conditionals
- **Lab 5**: Ansible Vault
- **Lab 6**: Testing e CI/CD

### **🏆 Desafios Avançados**

- Deploy aplicação completa (3-tier)
- Configuração de load balancer
- Backup e recovery automatizados
- Monitoring com Prometheus/Grafana
- CI/CD pipeline completo

## 🤝 Contribuições

Contribuições são bem-vindas!

1. **Fork** o projeto
2. **Crie** uma branch: `git checkout -b feature/nova-feature`
3. **Commit** suas mudanças: `git commit -m 'Add: nova feature'`
4. **Push** para branch: `git push origin feature/nova-feature`
5. **Abra** um Pull Request

### **Tipos de Contribuições**

- 🐛 **Bug fixes**
- ✨ **Novas features**
- 📚 **Documentação**
- 🎯 **Exercícios práticos**
- 🧪 **Novos cenários de teste**
- 🔧 **Melhorias de performance**

## 📄 Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 📞 Suporte

- **📧 Email**: rafael.friederick@gmail.com
- **🐙 Issues**: Use o sistema de issues do GitHub
- **💬 Discussões**: Aba Discussions do repositório

## 🙏 Agradecimentos

- **Ansible Community** - Pela excelente ferramenta
- **Docker** - Pela plataforma de containers
- **Debian Project** - Pela distribuição estável
- **Open Source Community** - Por tornar isso possível

---

<div align="center">

**🎉 Happy Learning with Ansible! 🎉**

_Construído com ❤️ para a comunidade DevOps_

[![Debian](https://img.shields.io/badge/Debian-13%20Trixie-red?style=flat&logo=debian)](https://www.debian.org/)
[![Docker](https://img.shields.io/badge/Docker-Latest-blue?style=flat&logo=docker)](https://www.docker.com/)
[![Ansible](https://img.shields.io/badge/Ansible-Latest-black?style=flat&logo=ansible)](https://www.ansible.com/)
[![Make](https://img.shields.io/badge/Make-GNU-green?style=flat&logo=gnu)](https://www.gnu.org/software/make/)

</div>

- [Ansible Youtube Video - DIOLINUX](https://www.youtube.com/watch?v=y5eKF_XnGyE)
- [Documentação Oficial do Ansible](https://docs.ansible.com/)
- [Ansible GitHub Repository](https://github.com/ansible/ansible)
