# playbooks/

> Orquestracao: o que executar e em quais hosts

## O que e

Playbooks descrevem a execucao do Ansible. Cada play define hosts,
variaveis e tarefas (ou roles) que serao aplicadas.

## Estrutura basica

```yaml
- name: Descricao
  hosts: grupo_ou_host
  become: true
  vars:
    exemplo: valor
  tasks:
    - name: Tarefa
      module: ...
  roles:
    - role_x
```

## Boas praticas

- Use `tags` para executar partes: `--tags k3s`.
- Mantenha tasks pequenas e idempotentes.
- Extraia logica para roles quando crescer.

## Execucao

```bash
ansible-playbook -i inventory/basic-hosts playbooks/arquivo.yml
```

Para variaveis sensiveis, use ansible-vault.
