# Modulo 07 - Node Affinity Preferred

## Objetivo

Demonstrar Node Affinity preferencial usando `preferredDuringSchedulingIgnoredDuringExecution`.

## Regra obrigatoria vs regra preferencial

- Regra obrigatoria (`requiredDuringSchedulingIgnoredDuringExecution`): o Pod so agenda em nodes que atendem a regra.
- Regra preferencial (`preferredDuringSchedulingIgnoredDuringExecution`): o scheduler tenta escolher o melhor node, mas nao bloqueia o agendamento se nao conseguir.

## Como funciona neste modulo

Este modulo aplica preferencia para nodes com label:

- `zone In [preferred]`
- `weight: 80`

Isso significa que nodes com `zone=preferred` recebem pontuacao maior na decisao de scheduling.

## Comportamento esperado da regra preferencial

Se houver nodes com `zone=preferred`, os Pods tendem a ser concentrados neles.  
Se esses nodes nao estiverem disponiveis ou nao tiverem capacidade suficiente, os Pods ainda podem ser agendados em outros nodes.

## Arquivos do modulo

- `namespace.yaml`
- `deployment-preferred-affinity.yaml`

## Scripts de apoio

- `scripts/label-nodes-for-preferred-affinity.sh`
- `scripts/remove-preferred-affinity-labels.sh`

## Execucao

1. Aplicar label no node alvo:

```bash
./scripts/label-nodes-for-preferred-affinity.sh
```

2. Aplicar manifests:

```bash
kubectl apply -f manifests/07-node-affinity-preferred/
```

## Validacao

```bash
kubectl get pods -n resilience-scheduling -o wide
kubectl describe deployment preferred-affinity-app -n resilience-scheduling
kubectl describe pod <nome-do-pod> -n resilience-scheduling
```

## Analise esperada dos resultados

1. Com label `zone=preferred` presente:
- maior tendencia de Pods no node rotulado.

2. Sem label ou sem capacidade no node preferido:
- Pods ainda sobem em outros nodes.
- nao deve haver bloqueio de agendamento apenas por falta da preferencia.

## Limpeza

```bash
./scripts/remove-preferred-affinity-labels.sh
kubectl delete -f manifests/07-node-affinity-preferred/deployment-preferred-affinity.yaml --ignore-not-found
```
