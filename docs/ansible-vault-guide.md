# 🔐 Ansible Vault - Guia Completo para o Lab

> **Gerenciamento seguro de credenciais com Ansible Vault**  
> Desenvolvido por: [@rafaelmfried](https://github.com/rafaelmfried)

## 📋 Visão Geral

O Ansible Vault é uma ferramenta que permite criptografar dados sensíveis como senhas, chaves SSH, certificados e outras credenciais. Neste lab, utilizamos o Vault para gerenciar de forma segura todas as informações confidenciais.

## 🏗️ Estrutura do Vault no Lab

```
ansible/
├── group_vars/all/
│   ├── main.yml           # Variáveis públicas
│   └── vault.yml          # 🔐 Variáveis criptografadas
├── .vault_pass            # 🔑 Arquivo de senha do Vault
├── ansible.cfg            # 📝 Configuração com Vault
└── playbooks/
    └── setup-ssh.yaml # 🔧 Playbook para SSH via Vault
```

## 🛠️ Instalação e Configuração

### 1. **Verificar Instalação do Ansible**
```bash
# O Vault já vem incluído com o Ansible
ansible-vault --help
```

### 2. **Configurar Senha do Vault**
```bash
# A senha já está configurada em .vault_pass
cat .vault_pass
# Output: ansible-lab-2026
```

### 3. **Verificar Configuração no ansible.cfg**
```bash
cat ansible.cfg | grep vault
# Deve mostrar: vault_password_file = .vault_pass
```

## 🔑 Operações com o Vault

### **Criar/Editar Arquivo Vault**
```bash
# Criar novo arquivo vault
ansible-vault create group_vars/all/secrets.yml

# Editar arquivo vault existente  
ansible-vault edit group_vars/all/vault.yml
```

### **Visualizar Conteúdo Criptografado**
```bash
# Ver conteúdo descriptografado
ansible-vault view group_vars/all/vault.yml

# Ver arquivo criptografado (não legível)
cat group_vars/all/vault.yml
```

### **Criptografar/Descriptografar Arquivos**
```bash
# Criptografar arquivo existente
ansible-vault encrypt arquivo_sensivel.yml

# Descriptografar arquivo
ansible-vault decrypt group_vars/all/vault.yml

# Re-criptografar após edição manual
ansible-vault encrypt group_vars/all/vault.yml
```

### **Alterar Senha do Vault**
```bash
# Alterar senha de um arquivo vault
ansible-vault rekey group_vars/all/vault.yml

# Alterar senha do arquivo de senha
echo \"nova-senha-super-segura\" > .vault_pass
```

## 📦 Conteúdo do Vault no Lab

### **group_vars/all/vault.yml** (Criptografado)
```yaml
# Segredos do lab
k3s_token: "SEU_TOKEN_DO_K3S"
lab_admin_password: "senha"
# db_root_password: "senha"
# api_token: "token"
```

### **group_vars/all/main.yml** (Publico)
```yaml
# Variaveis nao sensiveis
ssh_public_key: "ssh-ed25519 AAAAC3..."
maintainer_github: "rafaelmfried"
lab_name: "ansible-lab"
lab_version: "1.0"
control_node_ip: "198.18.100.10"
```

## 🎯 Casos de Uso no Lab

### **1. Configurar SSH Keys via Vault**
```bash
# Entrar no control node
make shell

# Executar playbook que usa Vault
ansible-playbook playbooks/setup-ssh.yaml

# Verificar se as keys foram configuradas
ansible all -m ping
```

### **2. Deploy com Credenciais Seguras**
```yaml
# playbooks/secure-deploy.yml
---
- name: Deploy seguro usando Vault
  hosts: webservers
  vars_files:
    - group_vars/all/vault.yml
  
  tasks:
    - name: Configurar banco com credenciais do Vault
      mysql_user:
        name: \"{{ db_user }}\"
        password: \"{{ db_password }}\"
        host: \"{{ db_host }}\"
```

### **3. Gerenciar Certificados SSL**
```yaml
# No vault.yml
ssl_private_key: |
  -----BEGIN PRIVATE KEY-----
  MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwgg...
  -----END PRIVATE KEY-----

ssl_certificate: |
  -----BEGIN CERTIFICATE-----
  MIIFXjCCA0agAwIBAgIJAK7Vw/5L5g5fMA0GCS...
  -----END CERTIFICATE-----
```

## 🔧 Comandos Avançados

### **Debug e Troubleshooting**
```bash
# Verificar sintaxe do vault
ansible-vault view group_vars/all/vault.yml --syntax-check

# Validar variáveis do vault em playbooks
ansible-playbook --syntax-check playbooks/setup-ssh.yaml

# Testar variáveis do vault
ansible all -m debug -a \"var=k3s_token\"
```

### **Backup e Segurança**
```bash
# Backup do arquivo vault (manter criptografado)
cp group_vars/all/vault.yml backups/vault_$(date +%Y%m%d).yml

# Verificar se arquivo está criptografado
file group_vars/all/vault.yml
# Output: group_vars/all/vault.yml: ASCII text

# Verificar hash do arquivo para integridade
sha256sum group_vars/all/vault.yml
```

### **Múltiplas Senhas de Vault**
```bash
# Usar diferentes IDs de vault
ansible-vault encrypt --vault-id prod@prompt group_vars/prod/vault.yml
ansible-vault encrypt --vault-id dev@.dev_vault_pass group_vars/dev/vault.yml

# Executar playbook com vault específico
ansible-playbook --vault-id prod@prompt playbooks/prod-deploy.yml
```

## 🚨 Boas Práticas de Segurança

### **1. Gestão de Senhas**
- ✅ Use senhas fortes e complexas
- ✅ Rotacione senhas periodicamente
- ✅ Nunca commite .vault_pass para Git
- ✅ Use diferentes senhas para diferentes ambientes

### **2. Separação de Dados**
```bash
# Estrutura recomendada
group_vars/
├── all/
│   ├── main.yml      # Dados públicos
│   └── vault.yml     # Dados sensíveis
├── production/
│   ├── main.yml      # Configs de produção
│   └── vault.yml     # Secrets de produção  
└── development/
    ├── main.yml      # Configs de dev
    └── vault.yml     # Secrets de dev
```

### **3. Controle de Acesso**
```bash
# Proteger arquivo de senha
chmod 600 .vault_pass
chown $(whoami):$(whoami) .vault_pass

# Adicionar ao .gitignore
echo \".vault_pass\" >> .gitignore
echo \"*.key\" >> .gitignore
echo \"*.pem\" >> .gitignore
```

### **4. Auditoria e Logs**
```bash
# Habilitar logs de vault no ansible.cfg
[defaults]
log_path = /var/log/ansible.log
vault_password_file = .vault_pass

# Verificar últimas modificações
stat group_vars/all/vault.yml
```

## 🔄 Integração com CI/CD

### **GitHub Actions**
```yaml
# .github/workflows/ansible.yml
name: Ansible Deploy
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Ansible
        run: pip install ansible
      - name: Deploy with Vault
        env:
          VAULT_PASSWORD: ${{ secrets.ANSIBLE_VAULT_PASSWORD }}
        run: |
          echo \"$VAULT_PASSWORD\" > .vault_pass
          chmod 600 .vault_pass
          ansible-playbook playbooks/deploy.yml
```

### **GitLab CI**
```yaml
# .gitlab-ci.yml
deploy:
  stage: deploy
  before_script:
    - echo \"$VAULT_PASSWORD\" > .vault_pass
    - chmod 600 .vault_pass
  script:
    - ansible-playbook playbooks/deploy.yml
  variables:
    VAULT_PASSWORD: $CI_VAULT_PASSWORD
```

## 🎓 Exercícios Práticos

### **Exercício 1: Básico**
```bash
# 1. Editar o vault
ansible-vault edit group_vars/all/vault.yml

# 2. Adicionar nova variável
new_secret: \"minha-nova-senha-secreta\"

# 3. Usar em playbook
ansible-playbook playbooks/test-vault.yml
```

### **Exercício 2: Intermediário**  
```bash
# 1. Criar vault para banco de dados
ansible-vault create group_vars/databases/vault.yml

# 2. Adicionar credenciais MySQL
mysql_root_password: \"super-senha-mysql\"
mysql_app_user: \"app_user\"
mysql_app_password: \"senha-do-app\"

# 3. Criar playbook para configurar MySQL
```

### **Exercício 3: Avançado**
```bash
# 1. Implementar rotação de chaves SSH
# 2. Usar vault-id para múltiplos ambientes
# 3. Integrar com pipeline CI/CD
```

## 🚨 Troubleshooting

### **Problemas Comuns**

#### **1. \"Vault password incorrect\"**
```bash
# Verificar senha
cat .vault_pass

# Testar manualmente
ansible-vault view group_vars/all/vault.yml --ask-vault-pass
```

#### **2. \"Vault format unhashable\"**
```bash
# Re-criptografar arquivo corrompido
ansible-vault decrypt group_vars/all/vault.yml
ansible-vault encrypt group_vars/all/vault.yml
```

#### **3. Variável não encontrada**
```bash
# Verificar se variável existe no vault
ansible-vault view group_vars/all/vault.yml | grep k3s_token

# Debug de variáveis
ansible all -m debug -a \"var=hostvars[inventory_hostname]\"
```

#### **4. Permissões de arquivo**
```bash
# Corrigir permissões
chmod 644 group_vars/all/vault.yml
chmod 600 .vault_pass
```

### **Debug Avançado**
```bash
# Verificar carregamento de variáveis
ansible-inventory --list --yaml

# Testar playbook em modo debug
ansible-playbook -vvv playbooks/setup-ssh.yaml

# Verificar sintaxe
ansible-playbook --syntax-check playbooks/setup-ssh.yaml
```

## 📚 Comandos de Referência Rápida

```bash
# === OPERAÇÕES BÁSICAS ===
ansible-vault create arquivo.yml          # Criar vault
ansible-vault edit arquivo.yml            # Editar vault  
ansible-vault view arquivo.yml            # Ver conteúdo
ansible-vault encrypt arquivo.yml         # Criptografar
ansible-vault decrypt arquivo.yml         # Descriptografar

# === GERENCIAMENTO DE SENHAS ===
ansible-vault rekey arquivo.yml           # Alterar senha
ansible-vault --ask-vault-pass            # Solicitar senha

# === EXECUÇÃO COM VAULT ===
ansible-playbook --ask-vault-pass play.yml
ansible-playbook --vault-password-file .vault_pass play.yml

# === VERIFICAÇÃO ===
ansible-vault view --vault-password-file .vault_pass grupo_vars/all/vault.yml
```

## 🎉 Conclusão

O Ansible Vault fornece uma camada robusta de segurança para o nosso lab, permitindo:

- ✅ **Credenciais seguras** sem exposição em código
- ✅ **Separação clara** entre dados públicos e privados  
- ✅ **Integração simples** com workflows existentes
- ✅ **Auditoria completa** de mudanças sensíveis
- ✅ **Escalabilidade** para múltiplos ambientes

Com essa implementação, o lab agora segue as melhores práticas de segurança, mantendo todas as credenciais protegidas enquanto preserva a facilidade de uso! 🔐

---

**💡 Próximos Passos:** 
- Implementar rotação automática de chaves
- Integrar com HashiCorp Vault
- Configurar múltiplos ambientes (dev/prod)
- Adicionar monitoring de acesso a secrets
