# Modulo 06 - Node Affinity Required

## Objetivo

Demonstrar Node Affinity obrigatoria com `requiredDuringSchedulingIgnoredDuringExecution`.

## Diferenca entre `nodeSelector` e Node Affinity

- `nodeSelector`: filtro simples de igualdade (`chave=valor`).
- Node Affinity: regras mais expressivas com operadores (`In`, `NotIn`, `Exists`, etc.) e modos obrigatorios ou preferenciais.

Neste modulo, usamos Node Affinity obrigatoria para exigir `disk In [ssd]`.

## Comportamento obrigatorio

Com `requiredDuringSchedulingIgnoredDuringExecution`, o Pod so pode ser agendado em nodes que atendam a regra.  
Se a regra nao for atendida, o Pod fica `Pending`.

## O que acontece sem label esperada

Se nenhum node tiver `disk=ssd`, o scheduler nao encontra node elegivel e registra eventos de `FailedScheduling`.

## Arquivos do modulo

- `namespace.yaml`
- `deployment-required-affinity.yaml`

## Scripts de apoio

- `scripts/label-nodes-for-required-affinity.sh`
- `scripts/remove-required-affinity-labels.sh`

## Execucao

1. Aplicar label no node worker:

```bash
./scripts/label-nodes-for-required-affinity.sh
```

2. Aplicar manifests:

```bash
kubectl apply -f manifests/06-node-affinity-required/
```

## Comandos de teste

```bash
kubectl get pods -n resilience-scheduling -o wide
kubectl describe pod <nome-do-pod> -n resilience-scheduling
kubectl get events -n resilience-scheduling --sort-by=.metadata.creationTimestamp
```

## Teste de falha controlada

Para observar comportamento sem node elegivel:

1. Remova as labels:

```bash
./scripts/remove-required-affinity-labels.sh
```

2. Recrie os Pods do deployment:

```bash
kubectl rollout restart deployment required-affinity-app -n resilience-scheduling
kubectl get pods -n resilience-scheduling
kubectl get events -n resilience-scheduling --sort-by=.metadata.creationTimestamp
```

Os Pods tendem a permanecer `Pending` ate existir pelo menos um node com `disk=ssd`.
