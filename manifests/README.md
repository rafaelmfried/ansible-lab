# Manifests do lab (K3s)

Esta pasta guarda recursos **locais** do lab (RBAC, ServiceAccounts, namespaces, etc).
Para aplicar tudo:

```bash
kubectl apply -k manifests
```

## Conteudo atual
- `admin-user.yaml`: cria um ServiceAccount com `cluster-admin` para o Dashboard (apenas para lab).

## Boas praticas
- Prefira aplicar manifests de terceiros via URL/Helm e manter aqui apenas ajustes locais.
- Evite commitar tokens ou credenciais em YAMLs deste diretorio.
