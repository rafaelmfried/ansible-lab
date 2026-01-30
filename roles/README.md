# roles/

> Funcoes reutilizaveis do Ansible

## O que e

Roles sao pacotes de tarefas reutilizaveis. Elas organizam arquivos, templates, handlers e variaveis de um componente.

## Estrutura basica

```text
roles/<nome>/
  tasks/main.yml
  handlers/main.yml
  templates/
  files/
  defaults/main.yml
  vars/main.yml
```

## Como usar em playbooks

```yaml
- name: Usar role
  hosts: all
  roles:
    - nome_da_role
```

Ou com `include_role`:

```yaml
- name: Usar role de forma dinamica
  hosts: all
  tasks:
    - name: Carregar role
      include_role:
        name: nome_da_role
```

## Defaults vs Vars

- `defaults/` tem menor prioridade (bom para valores padrao).
- `vars/` tem prioridade alta (use com cuidado).

## Dicas

- Uma role deve fazer uma coisa bem definida.
- Prefira parametros em `defaults` e documente na README da role.
