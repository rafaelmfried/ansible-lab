# coredns_dns

Role para subir CoreDNS + etcd como DNS interno do lab.

## O que faz

- Instala binaries do etcd e CoreDNS
- Cria serviços systemd
- Configura CoreDNS com plugin etcd
- Cria registros no etcd (DNS interno)

## Variáveis principais

- `dns_zone` (ex.: `lab.unnamed-lab.com`)
- `dns_upstream_servers` (ex.: `1.1.1.1`, `8.8.8.8`)
- `dns_records` (registros fixos)
- `dns_wildcards` (wildcards por usuário)

## Observação

Para clientes resolverem a zona interna, configure o DNS da VPN
para o IP do CoreDNS (ex.: `198.18.100.60`).
