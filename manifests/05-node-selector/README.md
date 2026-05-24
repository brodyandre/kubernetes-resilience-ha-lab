# Modulo 05 - Node Selector

## Objetivo

Demonstrar como aplicar labels em Nodes e usar `nodeSelector` para direcionar Pods para Nodes especificos.

## O que sao labels em Nodes

Labels em Nodes sao pares `chave=valor` usados para classificar capacidade, finalidade ou caracteristicas de cada node.  
Essas labels permitem que workloads sejam agendados de forma mais controlada.

## O que e nodeSelector

`nodeSelector` e uma forma simples de dizer ao scheduler que o Pod so pode rodar em nodes que tenham um label especifico.

Neste modulo:

- label esperada no node: `workload=resilience`
- regra no Pod: `nodeSelector.workload: resilience`

## Observacao sobre flexibilidade

`nodeSelector` e simples e direto, mas menos flexivel do que Node Affinity.  
Com affinity, e possivel definir regras obrigatorias e preferenciais com operadores mais ricos.

## Arquivos do modulo

- `namespace.yaml`
- `deployment-node-selector.yaml`

## Scripts de apoio

- `scripts/label-nodes-for-node-selector.sh`
- `scripts/remove-node-selector-labels.sh`

## Execucao

1. Aplicar label no node alvo:

```bash
./scripts/label-nodes-for-node-selector.sh
```

2. Aplicar manifests do modulo:

```bash
kubectl apply -f manifests/05-node-selector/
```

## Validacao

```bash
kubectl get pods -n resilience-scheduling -o wide
kubectl describe pod <nome-do-pod> -n resilience-scheduling
kubectl get nodes --show-labels
```

Ao descrever o Pod, verifique:

- Node onde o Pod foi agendado
- Node-Selectors aplicados no Pod

## Como remover labels depois

```bash
./scripts/remove-node-selector-labels.sh
```

Opcionalmente, remova tambem o deployment:

```bash
kubectl delete -f manifests/05-node-selector/deployment-node-selector.yaml --ignore-not-found
```
