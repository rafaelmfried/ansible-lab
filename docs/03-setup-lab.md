# 03 - Setup Inicial do Laboratório

**🏷️ Tags:** `#setup` `#basic` `#initial`  
**📅 Criado:** Janeiro 2026  
**👤 Autor:** [@rafaelmfried](https://github.com/rafaelmfried)

---

## 🎯 Objetivo

Realizar o **setup inicial completo** do laboratório Ansible, desde o clone do repositório até ter todos os containers rodando e funcionais.

---

## 📋 Checklist de Setup

### **✅ Pré-requisitos** (do guia anterior)

- [ ] Docker e Docker Compose instalados
- [ ] Ansible instalado e funcionando
- [ ] Git configurado
- [ ] SSH key no GitHub configurada
- [ ] Ferramentas auxiliares (make, curl, etc.)

### **🚀 Setup Inicial** (este guia)

- [ ] Repositório clonado
- [ ] Estrutura de diretórios criada
- [ ] Vault configurado
- [ ] Containers funcionando
- [ ] Conectividade Ansible testada

---

## 🏗️ Passo 1: Preparação do Ambiente

### **Clonar o Repositório**

```bash
# Ir para diretório de trabalho
cd ~/workspace

# Clonar repositório
git clone https://github.com/rafaelmfried/ansible-lab.git
cd ansible-lab

# Verificar estrutura inicial
tree -a -I '.git'
```

### **Verificar Estado Atual**

```bash
# Ver arquivos principais
ls -la

# Verificar se há arquivo vault (deve existir)
ls -la group_vars/all/

# Verificar templates
ls -la templates/

# Verificar Makefile
head -10 Makefile
```

### **Configurar Ambiente Local**

```bash
# Criar arquivo de password do vault
echo "ansible-lab-2026" > .vault_pass
chmod 600 .vault_pass

# Verificar se .gitignore protege o arquivo
grep -q ".vault_pass" .gitignore && echo "✅ Protegido" || echo "❌ Adicionar ao .gitignore"

# Verificar permissões
ls -la .vault_pass
# Deve mostrar: -rw------- 1 user user
```

---

## 🔧 Passo 2: Configuração do Vault

### **Verificar Vault Existente**

```bash
# Verificar se vault está criptografado
make vault-status

# Visualizar conteúdo do vault
make vault-view
```

### **Personalizar Credenciais (Opcional)**

Se quiser personalizar senhas ou adicionar suas próprias credenciais:

```bash
# Editar vault
make vault-edit

# Dentro do editor, você pode modificar:
# - vault_mysql_root_password
# - vault_postgres_password
# - vault_ssh_public_key (será sobrescrito pelo GitHub)
# - Adicionar novas credenciais
```

### **Verificar GitHub Integration**

```bash
# Verificar se sua chave SSH está no GitHub
make verify-github

# Deve mostrar algo como:
# ✅ GitHub SSH key found

# Buscar chave manualmente para verificar
curl -s https://github.com/SEU-USERNAME.keys
```

---

## 🐳 Passo 3: Preparação dos Containers

### **Verificar Templates**

```bash
# Gerar docker-compose.yml a partir do template
make generate-compose

# Verificar se arquivo foi criado
ls -la compose.yaml

# Visualizar configuração gerada
head -20 compose.yaml
```

### **Verificar Configuração Docker**

```bash
# Testar se docker está funcionando
docker --version
docker info

# Verificar se há containers antigos
docker ps -a

# Limpar ambiente se necessário (CUIDADO: remove todos os containers)
# docker system prune -af
```

### **Verificar Rede Docker**

```bash
# Ver redes existentes
docker network ls

# Verificar se há conflito com nossa rede 198.18.100.0/24
docker network inspect $(docker network ls -q) | grep -i "198.18" || echo "✅ Rede disponível"
```

---

## 🚀 Passo 4: Deploy Inicial

### **Deploy Completo Automatizado**

```bash
# Deploy com todas as verificações de segurança
make deploy-secure

# Este comando executa:
# 1. Verifica GitHub SSH key
# 2. Confirma vault está criptografado
# 3. Gera compose.yaml
# 4. Executa ansible-playbook deploy-lab.yml
```

### **Deploy Manual (Passo a Passo)**

Se preferir acompanhar cada etapa:

```bash
# 1. Verificações de segurança
make verify-github
make vault-status

# 2. Gerar arquivos de configuração
make generate-compose

# 3. Construir imagens Docker
docker-compose -f compose.yaml build --no-cache

# 4. Iniciar containers
docker-compose -f compose.yaml up -d

# 5. Aguardar inicialização (importante!)
sleep 30

# 6. Verificar status
docker-compose -f compose.yaml ps
```

### **Monitorar o Deploy**

```bash
# Acompanhar logs em tempo real
make logs

# Ou logs específicos de um container
docker-compose logs -f ansible-control

# Verificar status de saúde
make status
```

---

## 🔍 Passo 5: Verificação e Testes

### **Verificar Containers**

```bash
# Ver todos os containers
make show-containers

# Status detalhado
docker-compose ps

# Deve mostrar algo como:
# NAME             STATE    PORTS
# ansible-control  Up
# web1            Up       0.0.0.0:8081->80/tcp
# web2            Up       0.0.0.0:8082->80/tcp
# database        Up       0.0.0.0:3306->3306/tcp, 0.0.0.0:5432->5432/tcp
# app             Up       0.0.0.0:3000->3000/tcp, 0.0.0.0:6379->6379/tcp
```

### **Testar Conectividade SSH**

```bash
# Aguardar containers estarem totalmente inicializados
sleep 60

# Testar conectividade Ansible
make test-connectivity

# Deve mostrar algo como:
# web1 | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### **Teste Manual SSH**

```bash
# Conectar ao container de controle
docker exec -it ansible-control bash

# Dentro do container:
ansible --version
ansible all -m ping
ansible all -m setup | grep ansible_hostname

# Sair do container
exit
```

### **Verificar Serviços Web**

```bash
# Testar acesso aos serviços web
curl -I http://localhost:8081  # Web1
curl -I http://localhost:8082  # Web2
curl -I http://localhost:3000  # App

# Ou abrir no navegador:
# http://localhost:8081
# http://localhost:8082
# http://localhost:3000
```

---

## 🛠️ Passo 6: Configuração do Inventário

### **Verificar Inventário Ansible**

```bash
# Ver inventário atual
cat inventory/hosts

# Executar dentro do container de controle
docker exec ansible-control ansible-inventory --list

# Testar inventário
docker exec ansible-control ansible all --list-hosts
```

### **Personalizar Inventário (Se Necessário)**

```bash
# Editar inventário se precisar de grupos específicos
vim inventory/hosts

# Exemplo de personalização:
# [webservers]
# web1 ansible_host=198.18.100.21
# web2 ansible_host=198.18.100.22
#
# [databases]
# database ansible_host=198.18.100.31
#
# [applications]
# app ansible_host=198.18.100.41
```

---

## 📋 Passo 7: Verificação de Saúde Completa

### **Health Check Automatizado**

```bash
# Executar verificação completa
make validate-all

# Deve passar em todos os testes:
# ✅ Vault is encrypted
# ✅ Templates are valid
# ✅ No obvious secrets found in code
# ✅ All validations passed
```

### **Health Check Manual**

```bash
# 1. Containers rodando
echo "🐳 Containers:"
docker-compose ps | grep -v Exit

# 2. Conectividade Ansible
echo "🔌 Ansible Connectivity:"
docker exec ansible-control ansible all -m ping --one-line

# 3. Serviços respondendo
echo "🌐 Web Services:"
for port in 8081 8082 3000; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$port | grep -q "200\|404\|403"; then
        echo "  ✅ Port $port: Responding"
    else
        echo "  ❌ Port $port: Not responding"
    fi
done

# 4. Recursos do sistema
echo "💻 Resources:"
echo "  RAM: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "  Disk: $(df -h . | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
```

---

## 🐛 Troubleshooting Comum

### **Containers não iniciam**

```bash
# Verificar logs
docker-compose logs

# Verificar recursos
docker system df
df -h

# Limpar e tentar novamente
make clean-all
make deploy-secure
```

### **Conectividade SSH falha**

```bash
# Verificar se containers estão rodando
docker-compose ps

# Verificar rede
docker network ls
docker network inspect ansible-lab_ansible-learning-lab-network

# Reiniciar com delay maior
make down
sleep 10
make up
sleep 60
make test-connectivity
```

### **Vault não funciona**

```bash
# Verificar senha
cat .vault_pass

# Verificar se vault está criptografado
head -1 group_vars/all/vault.yml

# Testar manualmente
ansible-vault view group_vars/all/vault.yml --vault-password-file .vault_pass
```

### **Templates não geram**

```bash
# Verificar sintaxe do template
ansible-playbook --syntax-check playbooks/deploy-lab.yml

# Testar template manualmente
ansible -m template -a "src=templates/compose.yaml.j2 dest=/tmp/test-compose.yaml" localhost -vvv
```

---

## 🎉 Verificação de Sucesso

### **Critérios de Sucesso**

Para considerar o setup completo e bem-sucedido, você deve ter:

✅ **5 containers rodando**:

- ansible-control (Debian com Ansible)
- web1 (Debian com SSH)
- web2 (Debian com SSH)
- database (Debian com SSH)
- app (Debian com SSH)

✅ **Conectividade Ansible funcionando**:

```bash
docker exec ansible-control ansible all -m ping
# Todos os 4 nodes respondem "pong"
```

✅ **Serviços web respondendo**:

```bash
curl http://localhost:8081  # web1
curl http://localhost:8082  # web2
curl http://localhost:3000  # app
```

✅ **Vault seguro e funcional**:

```bash
make vault-view  # Mostra conteúdo descriptografado
make security-audit  # Sem secrets expostos
```

✅ **SSH funcionando entre containers**:

```bash
docker exec ansible-control ssh ansible@web1 'hostname'
# Retorna: web1
```

### **Screenshot de Sucesso**

```bash
# Comando para demonstrar funcionamento
echo "=== ANSIBLE LAB SETUP SUCCESS ==="
echo "Containers:"
docker-compose ps --format "table {{.Name}}\t{{.State}}\t{{.Ports}}"
echo ""
echo "Ansible Connectivity:"
docker exec ansible-control ansible all -m ping
echo ""
echo "Vault Status:"
make vault-status
echo ""
echo "=== READY FOR LEARNING! ==="
```

---

## 🔗 Próximos Passos

Agora que seu laboratório está funcionando, você pode:

1. **[04-conceitos-vault](04-conceitos-vault.md)** - Entender conceitos do Vault
2. **[08-automacao-makefile](08-automacao-makefile.md)** - Explorar automação
3. **[12-exemplos-playbooks](12-exemplos-playbooks.md)** - Executar playbooks práticos

---

## 💾 Comandos de Manutenção

### **Backup do Estado Atual**

```bash
# Backup do lab funcionando
make backup-vault

# Salvar configuração atual
docker-compose config > lab-config-backup.yml
```

### **Parar/Iniciar Rapidamente**

```bash
# Parar preservando dados
make stop

# Iniciar novamente
make start

# Restart completo
make restart
```

### **Limpeza Completa**

```bash
# Parar e limpar tudo (CUIDADO: perde dados)
make clean-all

# Restart completo do zero
make fresh-start
```

---

**Próximo:** Agora que o lab está funcionando, vamos entender os [conceitos fundamentais do Ansible Vault](04-conceitos-vault.md)!
