# host_vars/

> Variaveis especificas por host

## O que e

Arquivos com variaveis especificas de cada host do inventory. O nome do
arquivo deve bater exatamente com o nome do host.

## Como o Ansible usa

- `host_vars/<host>.yml` aplica somente ao host `<host>`.
- `host_vars/<host>/` pode conter varios arquivos YAML.

## Exemplo

Inventory:

```ini
vm1
```

`host_vars/vm1.yml`:

```yaml
nginx_port: 8080
```

## Precedencia (simplificado)

`host_vars` sobrescreve `group_vars`. Variaveis definidas no playbook
ou na linha de comando podem sobrescrever ambas.

## Dicas

- Use `host_vars` para diferencas reais entre hosts (IP, portas, flags).
- Segredos devem ficar em vault (ansible-vault) e nao em texto puro.
