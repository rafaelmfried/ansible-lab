# collections/

> Extensoes do Ansible (modulos, plugins e roles de terceiros)

## O que e

Collections sao pacotes que agrupam modulos, plugins e roles. Elas trazem
funcionalidades que nao fazem parte do Ansible core.

## Como o Ansible usa

- O Ansible procura collections em caminhos configurados por `ANSIBLE_COLLECTIONS_PATHS`.
- Neste repo, o diretorio `collections/` guarda dependencias locais.

## Estrutura tipica

```text
collections/
  ansible_collections/
    namespace/
      nome_collection/
```

## Como instalar

```bash
ansible-galaxy collection install -r collections/requirements.yml -p collections
```

Listar collections instaladas:

```bash
ansible-galaxy collection list
```

## Como referenciar no playbook

```yaml
- name: Exemplo com collection
  hosts: all
  tasks:
    - name: Usar modulo com namespace
      community.general.ufw:
        state: enabled
```

Ou declarar collections no playbook:

```yaml
- name: Exemplo
  hosts: all
  collections:
    - community.general
  tasks:
    - name: Usar modulo sem namespace
      ufw:
        state: enabled
```

## Dicas

- Fixe versoes no `requirements.yml` para evitar quebras.
- Prefira collections oficiais quando possivel.
