# 06 - Bastion WireGuard (vm4)

## Objetivo

Configurar a vm4 (grupo `bastion`) como servidor WireGuard para acesso seguro ao lab.

## Estrutura usada

- Playbook: `playbooks/setup-bastion-wireguard.yaml`
- Role: `roles/wireguard_bastion`
- Variaveis publicas: `group_vars/bastion/main.yml`
- Segredos (chave privada): `group_vars/bastion/vault.yml`

## Pre-requisitos

- Inventario com `vm4` no grupo `bastion`
- WireGuard instalado via playbook
- Arquivo `.vault_pass` configurado

## Gerar chaves do servidor (bastion)

Execute no vm4 (ou em qualquer host seguro):

```bash
wg genkey | tee /tmp/wg0.key | wg pubkey > /tmp/wg0.pub
```

- `/tmp/wg0.key` = **chave privada do servidor** (vai no vault)
- `/tmp/wg0.pub` = **chave publica do servidor** (vai nos clientes)

## Configurar o vault do bastion

```bash
cp group_vars/bastion/vault.yml.template group_vars/bastion/vault.yml
ansible-vault edit group_vars/bastion/vault.yml --vault-password-file .vault_pass
```

Exemplo:

```yaml
wg_private_key: "SUA_CHAVE_PRIVADA_DO_SERVIDOR"
```

## Configurar parametros publicos

Edite `group_vars/bastion/main.yml`:

```yaml
wg_interface: "wg0"
wg_address: "10.8.0.1/24"
wg_listen_port: 51820

# NAT automatico para acesso a rede interna
wg_enable_nat: true
wg_nat_interface: "eth0"
wg_nat_subnet: "10.8.0.0/24"

wg_peers:
  - public_key: "PUBKEY_CLIENTE1"
    allowed_ips: "10.8.0.2/32"
    persistent_keepalive: 25
```

> Ajuste a interface de saida (`eth0`) conforme sua VM.

## Rodar o playbook

```bash
ansible-playbook playbooks/setup-bastion-wireguard.yaml --vault-password-file .vault_pass
```

## Verificacoes rapidas

No vm4:

```bash
sudo systemctl status wg-quick@wg0 --no-pager
sudo wg show
ip a show wg0
```

## Exemplo de cliente (peer)

No cliente, gere a chave e crie um config como abaixo:

```ini
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY
Address = 10.8.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = pqzEecOC0JU8PoRxmxJPXO96k+jkmzFnSmFa1i+jIH8=
Endpoint = SEU_IP_PUBLICO:51820
AllowedIPs = 10.8.0.0/24
PersistentKeepalive = 25
```

## Troubleshooting

- **Erro: wg_private_key nao definido**
  - Verifique `group_vars/bastion/vault.yml`

- **Sem trafego**
  - Verifique `wg show`, `iptables -S` e se a porta 51820 esta aberta

- **Clientes nao conseguem pingar a rede**
  - Garanta `wg_ipv4_forward: true` e `wg_post_up` com NAT
