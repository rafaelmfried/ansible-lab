# inventory/

> Onde estao os hosts que o Ansible vai gerenciar

## O que e

O inventory define **quais maquinas** o Ansible controla e **como** se conecta a elas (hostnames, IPs, usuarios, portas).

## Arquivos deste diretorio

- `basic-hosts` (formato INI)

## Exemplo rapido (INI)

```ini
[web]
vm1 ansible_host=vm1

[db]
vm2 ansible_host=vm2

[all:vars]
ansible_user=ansible
ansible_ssh_pass=ansible
ansible_become=yes
```

## Como usar

```bash
ansible -i inventory/basic-hosts all -m ping
ansible-playbook -i inventory/basic-hosts playbooks/arquivo.yml
```

## Dicas

- Nomes em `host_vars/` e `group_vars/` devem bater com os do inventory.
- Evite senhas em texto puro; prefira ansible-vault.
