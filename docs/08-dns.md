# DNS Interno (CoreDNS + etcd)

Este modulo cria um DNS interno para o lab usando CoreDNS com backend em etcd.
O DNS interno permite **split-horizon**: nomes resolvem para IPs privados
apenas quando o usuario esta na VPN.

## Objetivo

- Servir a zona interna `lab.unnamed-lab.com`
- Permitir subdominios por usuario, ex:
  - `rafael.lab.apps.unnamed-lab.com`
  - `rafael.lab.postgres.unnamed-lab.com`
- A aplicacao Go podera criar/remover registros dinamicamente no etcd

## CoreDNS (shared)

O CoreDNS + etcd roda no container **coredns** (IP `198.18.100.60`).

> **Host vs container:** se voce roda o Ansible fora do `ansible-control`,
> o nome `coredns` pode nao resolver. Nesse caso, ajuste o inventory para
> `ansible_host=198.18.100.60`.

## Playbook

```
ansible-playbook playbooks/setup-dns.yaml
```

## Variaveis (group_vars/dns/main.yml)

- `dns_zone`: zona interna (ex.: `lab.unnamed-lab.com`)
- `dns_upstream_servers`: resolvers externos (fallback)
- `dns_records`: registros fixos
- `dns_wildcards`: wildcards para multi-tenant

## Integração com WireGuard

Defina o DNS dos clientes da VPN para `198.18.100.60`:

- `group_vars/bastion/main.yml`:
  - `wg_client_dns: "198.18.100.60"`

Assim, quando o usuario estiver na VPN, os subdominios internos resolvem
automaticamente para IPs privados.

## Registros no etcd (formato SkyDNS)

CoreDNS usa o caminho `/skydns` no etcd. Exemplo de registro:

```
etcdctl put /skydns/com/unnamed-lab/lab/apps/rafael '{"host":"198.18.100.20","ttl":60}'
```

Sua aplicacao Go pode usar esse formato para criar/remover registros.
