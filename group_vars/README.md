# group_vars/

> Variaveis por grupo (inclui `all` para todos os hosts)

## O que e

Variaveis compartilhadas por grupos do inventory. O subdiretorio `all`
aplica a todos os hosts.

## Como o Ansible usa

- `group_vars/<grupo>.yml` aplica ao grupo `<grupo>`.
- `group_vars/<grupo>/` pode conter varios arquivos YAML.
- `group_vars/all/` aplica a todos os hosts.

## Exemplo

Inventory:

```ini
[database]
vm5
```

`group_vars/database.yml`:

```yaml
db_port: 5432
```

## Precedencia (simplificado)

`group_vars` < `host_vars`. Variaveis definidas no playbook podem sobrescrever `group_vars`.

## Dicas

- Coloque defaults globais em `group_vars/all`.
- Use nomes de grupos iguais aos do inventory.
