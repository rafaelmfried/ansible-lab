# 04 - Conceitos do Ansible Vault

**🏷️ Tags:** `#security` `#vault` `#concepts`  
**📅 Criado:** Janeiro 2026  
**👤 Autor:** [@rafaelmfried](https://github.com/rafaelmfried)

---

## 🔐 O que é Ansible Vault?

### **Definição**
O **Ansible Vault** é uma funcionalidade nativa do Ansible que permite **criptografar dados sensíveis** em arquivos YAML, mantendo-os seguros em repositórios de código.

### **Problema que Resolve**
```yaml
# ❌ NUNCA FAÇA ISSO (dados sensíveis expostos)
database_password: "super-secret-password"
api_key: "abc123def456ghi789"
ssh_private_key: |
  -----BEGIN PRIVATE KEY-----
  MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwgg...
```

```yaml
# ✅ COM VAULT (dados protegidos)
$ANSIBLE_VAULT;1.1;AES256
66373562386663653933636366386234333730613965393635626466646631666561376634303062
3064643765333462623961623631323933393964373362610a366561386366633865386539623262
```

---

## 🎯 Por Que Usar Vault?

### **1. Segurança em Repositórios Públicos**
- **Credenciais protegidas** mesmo em repos públicos
- **Histórico seguro** - secrets nunca expostos
- **Compliance** com políticas de segurança
- **Auditoria** de mudanças em secrets

### **2. Separação de Responsabilidades**
- **Desenvolvedores**: Trabalham com templates
- **SysAdmins**: Gerenciam secrets reais
- **DevOps**: Implementam pipelines seguros
- **Security**: Auditam e rotacionam credenciais

### **3. Flexibilidade Operacional**
- **Múltiplos ambientes** (dev/stage/prod)
- **Diferentes níveis** de acesso
- **Rotação** de credenciais simplificada
- **Backup e recovery** seguros

---

## 🏗️ Como Funciona o Vault?

### **Fluxo de Operação**

```mermaid
graph LR
    A[Arquivo Texto] --> B[ansible-vault encrypt]
    B --> C[Arquivo Criptografado]
    C --> D[ansible-vault decrypt]
    D --> E[Ansible Playbook]
    E --> F[Deployment Seguro]
    
    G[Vault Password] --> B
    G --> D
```

### **Algoritmo de Criptografia**
- **AES-256**: Criptografia simétrica robusta
- **Salt único**: Cada arquivo tem salt diferente
- **HMAC**: Verificação de integridade
- **PBKDF2**: Key derivation function

### **Estrutura do Arquivo Vault**
```
$ANSIBLE_VAULT;1.1;AES256
^              ^   ^
│              │   └── Algoritmo
│              └────── Versão do formato
└───────────────────── Header identificador
```

---

## 📁 Organização de Arquivos

### **Estrutura Recomendada**
```
project/
├── group_vars/
│   ├── all/
│   │   ├── main.yml      # 📝 Variáveis públicas
│   │   └── vault.yml     # 🔐 Variáveis criptografadas
│   ├── production/
│   │   ├── main.yml      # 📝 Configs de produção
│   │   └── vault.yml     # 🔐 Secrets de produção
│   └── development/
│       ├── main.yml      # 📝 Configs de desenvolvimento
│       └── vault.yml     # 🔐 Secrets de desenvolvimento
├── .vault_pass           # 🔑 Senha do vault (NÃO commitar)
└── ansible.cfg           # ⚙️ Configuração com vault
```

### **Convenção de Nomenclatura**
```yaml
# main.yml (público)
app_name: "minha-aplicacao"
app_port: 8080
app_environment: "production"

# vault.yml (criptografado)  
app_database_password: "super-secret-password"
app_api_key: "abc123def456"
app_ssl_private_key: |
  -----BEGIN PRIVATE KEY-----
  ...
```

---

## 🛡️ Tipos de Dados para o Vault

### **Sempre Criptografar**
- ✅ Senhas e passphrases
- ✅ Chaves de API e tokens
- ✅ Certificados e chaves privadas
- ✅ Strings de conexão de banco
- ✅ Credenciais de terceiros
- ✅ Chaves SSH privadas

### **Pode Ficar Público**
- ✅ Nomes de aplicações
- ✅ Portas e configurações de rede
- ✅ URLs públicas
- ✅ Configurações de ambiente (não sensíveis)
- ✅ Metadados de deployment

### **Zona Cinza (Avaliar caso a caso)**
- 🤔 Usernames (dependendo do contexto)
- 🤔 Nomes de bancos de dados
- 🤔 Hostnames internos
- 🤔 Configurações de debug

---

## 🔑 Gerenciamento de Senhas

### **Métodos de Autenticação**

#### **1. Arquivo de Senha** (Recomendado para labs)
```bash
# .vault_pass
ansible-lab-2026
```

```ini
# ansible.cfg
[defaults]
vault_password_file = .vault_pass
```

#### **2. Prompt Interativo** (Recomendado para produção)
```bash
ansible-playbook --ask-vault-pass playbook.yml
```

#### **3. Script de Senha** (Avançado)
```bash
# vault_password_script.sh
#!/bin/bash
echo $VAULT_PASSWORD
```

```ini
# ansible.cfg
[defaults]
vault_password_file = ./vault_password_script.sh
```

#### **4. Múltiplas Senhas** (Empresarial)
```bash
ansible-vault encrypt --vault-id prod@prompt vars/prod.yml
ansible-vault encrypt --vault-id dev@.dev_pass vars/dev.yml
```

---

## 🎭 Casos de Uso Práticos

### **Caso 1: Desenvolvimento Local**
```bash
# Developer workflow
git clone projeto
echo "dev-password-123" > .vault_pass
ansible-vault edit group_vars/all/vault.yml
ansible-playbook deploy.yml
```

### **Caso 2: CI/CD Pipeline**
```yaml
# GitHub Actions
- name: Deploy with Vault
  env:
    VAULT_PASSWORD: ${{ secrets.ANSIBLE_VAULT_PASSWORD }}
  run: |
    echo "$VAULT_PASSWORD" > .vault_pass
    ansible-playbook deploy.yml
    rm .vault_pass
```

### **Caso 3: Múltiplos Ambientes**
```bash
# Production
ansible-playbook --vault-id prod@prompt site.yml

# Development  
ansible-playbook --vault-id dev@.dev_pass site.yml

# Staging
ansible-playbook --vault-id stage@stage_script.sh site.yml
```

### **Caso 4: Rotação de Credenciais**
```bash
# 1. Decrypt current vault
ansible-vault decrypt group_vars/prod/vault.yml

# 2. Update credentials
vim group_vars/prod/vault.yml

# 3. Re-encrypt with new password
ansible-vault encrypt group_vars/prod/vault.yml

# 4. Update password file
echo "new-super-secure-password" > .vault_pass
```

---

## ⚠️ Armadilhas Comuns

### **1. Commitar Senhas por Acidente**
```bash
# ❌ NUNCA faça isso
git add .vault_pass
git commit -m "Add vault password"

# ✅ Use .gitignore
echo ".vault_pass" >> .gitignore
echo "*.vault_pass" >> .gitignore
```

### **2. Usar a Mesma Senha Everywhere**
```bash
# ❌ Perigoso
dev_vault_pass: "123456"
prod_vault_pass: "123456"  # Same password!

# ✅ Senhas diferentes por ambiente
dev_vault_pass: "dev-secure-2026"
prod_vault_pass: "prod-ultra-secure-2026"
```

### **3. Vault Files Não Criptografados**
```bash
# Verificar se arquivo está criptografado
head -1 group_vars/all/vault.yml
# Deve mostrar: $ANSIBLE_VAULT;1.1;AES256

# Se não estiver, criptografar
ansible-vault encrypt group_vars/all/vault.yml
```

### **4. Permissions Inadequadas**
```bash
# ✅ Proteger arquivo de senha
chmod 600 .vault_pass
chown $(whoami):$(whoami) .vault_pass

# ✅ Verificar
ls -la .vault_pass
# -rw------- 1 user user 15 Jan 30 10:00 .vault_pass
```

---

## 🔍 Debugging e Troubleshooting

### **Verificar se Vault Funciona**
```bash
# 1. Verificar sintaxe
ansible-vault view group_vars/all/vault.yml --syntax-check

# 2. Testar descriptografia
ansible-vault view group_vars/all/vault.yml

# 3. Verificar variáveis em playbook
ansible all -m debug -a "var=vault_variable"
```

### **Problemas Comuns**
```bash
# Erro: "Vault password incorrect"
Solution: Verificar conteúdo de .vault_pass

# Erro: "Vault format unhashable" 
Solution: Re-criptografar arquivo
ansible-vault decrypt vault.yml
ansible-vault encrypt vault.yml

# Erro: "Variable undefined"
Solution: Verificar nome da variável no vault
ansible-vault view group_vars/all/vault.yml | grep variable_name
```

---

## 📈 Boas Práticas

### **1. Naming Conventions**
```yaml
# Prefixe variáveis do vault
vault_database_password: "secret123"
vault_api_key: "abc123"
vault_ssl_cert: |
  -----BEGIN CERTIFICATE-----
```

### **2. Documentação**
```yaml
# vault.yml
# Secrets para aplicação XYZ
# Última atualização: 2026-01-30
# Responsável: @rafaelmfried

vault_db_password: "encrypted-password"  # MySQL root password
vault_api_token: "encrypted-token"       # External API token
```

### **3. Backup Strategy**
```bash
# Backup regular dos vaults
cp group_vars/all/vault.yml backups/vault_$(date +%Y%m%d).yml

# Verificar integridade
sha256sum group_vars/all/vault.yml > vault.sha256
```

### **4. Access Control**
```bash
# Diferentes permissões por ambiente
chmod 600 .vault_pass_dev    # Developer access
chmod 400 .vault_pass_prod   # Read-only for production
```

---

## 🎓 Exercícios Práticos

### **Exercício 1: Básico**
1. Criar arquivo com dados sensíveis
2. Criptografar com vault
3. Verificar se está protegido
4. Descriptografar e verificar conteúdo

### **Exercício 2: Integração**
1. Criar playbook que usa vault
2. Executar com senha via prompt
3. Executar com arquivo de senha
4. Verificar deploy funcionando

### **Exercício 3: Múltiplos Ambientes**
1. Criar vaults para dev/prod
2. Configurar senhas diferentes
3. Deploy em ambientes diferentes
4. Verificar isolamento

---

## 🔗 Próximos Passos

1. **[05-protegendo-secrets](05-protegendo-secrets.md)** - Remover secrets do código
2. **[06-configuracao-vault](06-configuracao-vault.md)** - Setup prático no lab
3. **[07-workflow-vault](07-workflow-vault.md)** - Workflow completo

---

## 💡 Dicas Finais

- 🔐 **Vault não é backup** - sempre tenha backup das senhas
- 🔄 **Rotacione senhas** regularmente
- 📝 **Documente** responsáveis por cada vault
- 🧪 **Teste** restore procedures periodicamente
- 🚫 **Nunca** commite arquivos .vault_pass
- ✅ **Sempre** use .gitignore adequado

---

**Próximo:** Agora que você entende os conceitos, vamos ver como [proteger secrets existentes](05-protegendo-secrets.md) no nosso lab!