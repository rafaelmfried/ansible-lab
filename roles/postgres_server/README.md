# role: postgres_server

Provisiona PostgreSQL via apt (PGDG) no host do grupo `database`.

## Variaveis principais

- `postgres_version` (default: `18`)
- `postgres_listen_addresses` (default: `*`)
- `postgres_port` (default: `5432`)
- `postgres_allowed_cidrs` (lista de redes permitidas)
- `postgres_app_user`, `postgres_app_password`, `postgres_app_db` (opcionais)

## Uso

```yaml
- hosts: database
  roles:
    - role: postgres_server
```
