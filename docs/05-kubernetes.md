# 05 - Kubernetes (K3s/K3d no lab)

## Objetivo

Provisionar um cluster K3s dentro das VMs do lab (estilo k3d) usando Ansible.

## Estrutura usada

- Playbook: `playbooks/setup-k3s.yaml`
- Role: `roles/k3s_server`
- Variaveis globais do cluster: `group_vars/k3s.yml`
- Variaveis do host do control-plane: `host_vars/vm3.yml`
- Segredos (token): `group_vars/all/vault.yml`

## Pre-requisitos

1. Lab rodando e acessivel pelo ansible-control
2. Token do K3s definido no vault (variavel `k3s_token`)
3. Inventario contendo o grupo `k3s` (aponta para `vm3`)

## Provisionamento basico (via playbook)

No `ansible-control`:

```bash
ansible-playbook playbooks/setup-k3s.yaml --vault-password-file .vault_pass
```

O playbook:

- instala dependencias
- instala o K3s
- valida o status do servico
- gera o kubeconfig em `/etc/rancher/k3s/k3s.yaml`
- copia o kubeconfig para `/home/ansible/.kube/config`

## Verificacoes rapidas

No `vm3` (ou via ansible-control):

```bash
systemctl status k3s-testcluster --no-pager
kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes
```

## Acesso do host local (via tunnel SSH)

1. Abra o tunnel do seu PC para o host (192.168.0.83):

```bash
ssh -L 6444:198.18.100.30:6443 rafael@192.168.0.83 -N
```

2. Pegue o kubeconfig do vm3 e copie para sua maquina:

```bash
# no host 192.168.0.83
docker exec -it vm3 cat /etc/rancher/k3s/k3s.yaml > /tmp/k3s-vm3.yaml

# no seu PC
scp rafael@192.168.0.83:/tmp/k3s-vm3.yaml ./k3s-vm3.yaml
```

3. Ajuste o `server:` para usar o tunnel:

```
server: https://127.0.0.1:6444
```

4. Use o kubectl local:

```bash
KUBECONFIG=./k3s-vm3.yaml kubectl get nodes
```

## Bootstrap inicial do cluster (manifests/)

Use a pasta `manifests/` para recursos locais do lab (RBAC, namespaces, etc). Para aplicar tudo de uma vez:

```bash
KUBECONFIG=./k3s-vm3.yaml kubectl apply -k manifests
```

> Observacao: `manifests/admin-user.yaml` cria um `cluster-admin` (apenas para lab).

## UI do Kubernetes (Dashboard)

```bash
KUBECONFIG=./k3s-vm3.yaml kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
KUBECONFIG=./k3s-vm3.yaml kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard 8443:443
```

Abra: `https://127.0.0.1:8443`

Para gerar token:

```bash
KUBECONFIG=./k3s-vm3.yaml kubectl -n kubernetes-dashboard create token admin-user
```

## Onde ajustar variaveis

- `group_vars/k3s.yml`: nome do cluster e snapshotter
- `host_vars/vm3.yml`: nome do node (control-plane)
- `group_vars/all/vault.yml`: `k3s_token`

Se precisar trocar o host do K3s, mova o host para o grupo `k3s` no inventory.
