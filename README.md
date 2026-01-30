# 🔥 Ansible Lab - VMs Básicas

**Laboratório de aprendizado com 5 VMs Debian prontas para configuração**

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://ansible.com)
[![UFW](https://img.shields.io/badge/UFW-FF6B35?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)](https://debian.org)

> **Ambiente prático para aprender Ansible com 5 VMs básicas prontas para configuração de serviços**

---

## 🎯 Objetivo

Este laboratório fornece **5 VMs Debian** básicas prontas para configuração, ideal para:

- ✅ **Aprender Ansible** com ambiente realista
- ✅ **Praticar automação** de configuração de serviços
- ✅ **Configurar infraestrutura** (firewall, kubernetes, proxy, VPN, database)
- ✅ **Implementar playbooks** especializados
- ✅ **Testar cenários** em ambiente controlado

## 🏗️ Arquitetura

```
                    🌐 HOST MACHINE
                           │
               ┌───────────▼───────────┐
               │    LAB NETWORK       │
               │   198.18.100.0/24    │
               └───────────┬───────────┘
                           │
        ┌──────┬──────┬────┼────┬──────┐
        │      │      │    │    │      │
        ▼      ▼      ▼    ▼    ▼      │
   ┌─────────────────────────────────┐  │
   │  VM1     VM2     VM3    VM4    │  │
   │ .10      .20     .30    .40    │  │
   │ Basic    Basic   Basic  Basic  │  │
   │         VM5                    │  │
   │        .50                     │  │
   │       Basic                    │  │
   └─────────────────────────────────┘  │
                                        │
              ┌─────────────────────────┘
              ▼
   ┌─────────────────────────┐
   │    ANSIBLE-CONTROL      │
   │      (OPCIONAL)         │
   │     198.18.100.100      │
   │   Gerenciamento Central  │
   └─────────────────────────┘
```

### **🖥️ VMs do Laboratório**

| VM                  | IP             | Função Futura       | Estado Atual         |
| ------------------- | -------------- | ------------------- | -------------------- |
| **vm1**             | 198.18.100.10  | Firewall/Gateway    | VM básica Debian     |
| **vm2**             | 198.18.100.20  | Kubernetes Nodes    | VM básica Debian     |
| **vm3**             | 198.18.100.30  | Proxy/Load Balancer | VM básica Debian     |
| **vm4**             | 198.18.100.40  | Bastion/VPN         | VM básica Debian     |
| **vm5**             | 198.18.100.50  | PostgreSQL Database | VM básica Debian     |
| **ansible-control** | 198.18.100.100 | Automation Hub      | Opcional (comentado) |

### **📋 Configuração Atual**

```bash
# Todas as VMs são básicas com:
✅ Debian 12 slim
✅ SSH server configurado
✅ Usuário 'ansible' com sudo
✅ Python3 para Ansible
✅ Ferramentas essenciais

# Prontas para configuração via Ansible:
🔄 Firewall UFW/iptables (vm1)
🔄 Cluster Kubernetes (vm2)
🔄 Nginx Proxy/Load Balancer (vm3)
🔄 WireGuard VPN + Bastion (vm4)
🔄 PostgreSQL Database (vm5)
```

## 🛠️ Tecnologias

- **🐧 SO Base**: Debian 12 slim em containers Docker
- **⚙️ Automação**: Ansible para configurar toda infraestrutura
- **🌐 Network**: Docker bridge com IPs fixos (198.18.100.0/24)
- **🔑 SSH**: Chaves compartilhadas via volumes
- **📊 Monitoramento**: Logs centralizados para auditoria
- **📦 Container**: Docker Compose para gerenciamento

## 🚀 Quick Start

### **1. Deploy das VMs Básicas**

```bash
# 1. Clonar repositório
git clone <repo-url>
cd ansible

# 2. Iniciar VMs básicas (5 VMs Debian)
docker-compose up -d

# 3. Verificar status
docker-compose ps

# 4. Testar conectividade
for i in {1..5}; do
  echo "Testing vm$i..."
  docker exec vm$i hostname
done
```

### **2. Usar Ansible (Opcional)**

```bash
# Opção A: Ansible Control centralizado
# Descomente no compose.yaml e execute:
# docker-compose up -d ansible-control
# docker exec -it ansible-control bash

# Opção B: Ansible local (recomendado para desenvolvimento)
# Instalar Ansible localmente e configurar inventory:
ansible all -i "vm1,vm2,vm3,vm4,vm5," -m ping \
  --ssh-common-args="-o StrictHostKeyChecking=no" \
  -u ansible -k
```

### **3. Comandos Úteis**

```bash
# 📊 Status das VMs
docker-compose ps

# 🔗 Acessar uma VM específica
docker exec -it vm1 bash  # ou vm2, vm3, vm4, vm5

# 🧪 Teste conectividade entre VMs
docker exec vm1 ping -c 2 vm2

# 📋 Listar IPs das VMs
docker network inspect ansible_lab_network | grep -A 3 -B 1 "vm[1-5]"

# 🛑 Parar ambiente
docker-compose down
```

## 📚 Próximas Configurações via Ansible

### **Roadmap de Configuração**

#### **Fase 1: VM1 - Firewall**

```yaml
# playbook: setup-firewall.yml
- Configure UFW/iptables
- Setup as gateway (IP forwarding)
- Network access control
- Logging and monitoring
```

#### **Fase 2: VM2 - Kubernetes**

```yaml
# playbook: setup-kubernetes.yml
- Install Docker/containerd
- Setup Kubernetes cluster (kubeadm)
- Configure master/worker nodes
- Deploy basic ingress
```

#### **Fase 3: VM3 - Proxy**

```yaml
# playbook: setup-proxy.yml
- Install Nginx/HAProxy
- Load balancing configuration
- SSL termination
- Health checks
```

#### **Fase 4: VM4 - Bastion**

```yaml
# playbook: setup-bastion.yml
- Install WireGuard VPN
- SSH jump host setup
- Access control and audit
- Connection monitoring
```

#### **Fase 5: VM5 - Database**

```yaml
# playbook: setup-database.yml
- Install PostgreSQL
- Database security hardening
- Backup automation
- Performance tuning
```

### **Estrutura de Inventário**

```ini
# inventory/hosts
[firewall]
vm1 ansible_host=198.18.100.10

[kubernetes]
vm2 ansible_host=198.18.100.20

[proxy]
vm3 ansible_host=198.18.100.30

[bastion]
vm4 ansible_host=198.18.100.40

[database]
vm5 ansible_host=198.18.100.50

[all:vars]
ansible_user=ansible
ansible_ssh_pass=ansible
ansible_become=yes
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

---

## 🧪 Validação Básica

### **Testes de Conectividade**

```bash
# ✅ Ping entre VMs
for i in {1..5}; do
  docker exec vm1 ping -c 1 vm$i
done

# ✅ SSH entre VMs (sem Ansible Control)
docker exec vm1 ssh ansible@vm2 "hostname"

# ✅ Com Ansible local
ansible all -i inventory/hosts -m ping

# ✅ Verificar usuários e sudo
ansible all -i inventory/hosts -m shell -a "whoami && sudo whoami"
```

### **Estado Atual**

- ✅ **5 VMs Debian** rodando e conectadas
- ✅ **SSH configurado** entre todas VMs
- ✅ **Network funcionando** (198.18.100.0/24)
- ✅ **Pronto para configuração** via Ansible
- ✅ **Ansible Control opcional** (descomentado conforme necessário)

## 📖 Documentação

### **Guias Principais**

- [`docs/01-introducao.md`](docs/01-introducao.md) → **Introdução e objetivos**
- [`docs/setup_lab.md`](docs/setup_lab.md) → **Setup detalhado**
- [`firewall/rules.conf`](firewall/rules.conf) → **Regras do firewall**

### **Playbooks Incluídos**

```bash
playbooks/
├── setup-basic.yml      # Configuração inicial das VMs
├── setup-firewall.yml   # Configuração UFW
├── webserver.yml        # Deploy nginx
├── database.yml         # Setup PostgreSQL
└── monitoring.yml       # Logs e auditoria
```

## 🔮 Próximos Passos

Após dominar este lab, você pode expandir para:

- [ ] **Múltiplas redes** isoladas
- [ ] **Load balancing** com HAProxy
- [ ] **Container orchestration** com Docker Swarm
- [ ] **CI/CD pipeline** com GitLab
- [ ] **Monitoring avançado** com Prometheus

---

## 🤝 Contribuições

1. Fork o projeto
2. Crie feature branch (`git checkout -b feature/nova-feature`)
3. Commit mudanças (`git commit -am 'Add nova feature'`)
4. Push para branch (`git push origin feature/nova-feature`)
5. Abra Pull Request

---

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

**🎯 Resultado:** Ambiente completo para dominar Ansible com VMs reais e firewall! 🚀
