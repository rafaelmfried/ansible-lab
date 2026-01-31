# roles/

> Roles sao unidades reutilizaveis no Ansible. A comunidade recomenda manter cada role pequena, coesa e bem documentada.

## Estrutura recomendada

```
roles/<nome-da-role>/
  tasks/              # Tarefas da role (main.yml e includes)
  handlers/           # Handlers (restart, reload, etc)
  templates/          # Jinja2 templates (arquivos .j2)
  files/              # Arquivos estaticos para copy
  defaults/           # Variaveis com menor prioridade
  vars/               # Variaveis com maior prioridade (use com cuidado)
  meta/               # Metadados da role (dependencias, galaxy_info)
  tests/              # Playbooks simples para testar a role
  README.md           # Documentacao especifica da role
```

## O que vai em cada pasta

- **tasks/**
  - `main.yml` e arquivos auxiliares (`install.yml`, `config.yml`, `bootstrap.yml`)
  - Boas praticas: dividir por etapas e usar `include_tasks`.

- **handlers/**
  - Acoes acionadas por `notify` (ex.: reiniciar servico)

- **templates/**
  - Arquivos `.j2` que precisam de variaveis (ex.: configs)

- **files/**
  - Arquivos estaticos (certificados, scripts, etc.)

- **defaults/**
  - Valores padrao, sempre sobrescreviveis

- **vars/**
  - Variaveis com prioridade alta (evite se puder usar defaults)

- **meta/**
  - `meta/main.yml` com dependencias e informacoes da role

- **tests/**
  - Playbooks pequenos para validar a role isoladamente

## Boas praticas da comunidade

- Uma role deve fazer **uma coisa bem definida**.
- Prefira variaveis em `defaults/` e documente no README da role.
- Evite logar segredos: use `no_log: true` quando necessario.
- Use `handlers` para restart/reload.
- Mantenha nomes consistentes (`wireguard_bastion`, `k3s_server`).

## Como usar em playbooks

```yaml
- name: Usar role
  hosts: all
  roles:
    - nome_da_role
```

## Uso dinamico

```yaml
- name: Carregar role por tarefa
  hosts: all
  tasks:
    - name: Carregar role
      include_role:
        name: nome_da_role
```
