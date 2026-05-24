# Modulo 10 - Taints e Tolerations

## Objetivo

Demonstrar como taints e tolerations controlam quais Pods podem (ou nao) ser agendados em determinados nodes.

## Taints em linguagem simples

Um taint funciona como um "repelente" no node.  
Com `NoSchedule`, novos Pods sem toleration compativel nao devem ser agendados nesse node.

## Tolerations em linguagem simples

Uma toleration no Pod diz que ele aceita aquele taint especifico.  
Importante: toleration permite o agendamento no node taintado, mas nao garante que o scheduler escolha esse node.

## O que significa `NoSchedule`

`NoSchedule` impede o agendamento de novos Pods que nao toleram o taint.  
Pods ja em execucao normalmente nao sao removidos por esse efeito.

## Arquivos do modulo

- `namespace.yaml`
- `pod-without-toleration.yaml`
- `pod-with-toleration.yaml`

## Scripts de apoio

- `scripts/apply-dedicated-node-taint.sh`
- `scripts/remove-dedicated-node-taint.sh`

## Fluxo de teste sugerido

1. Aplicar taint e label no node dedicado:

```bash
./scripts/apply-dedicated-node-taint.sh
```

2. Aplicar namespace:

```bash
kubectl apply -f manifests/10-taints-tolerations/namespace.yaml
```

3. Testar Pod sem toleration (deve tender a falhar no agendamento):

```bash
kubectl apply -f manifests/10-taints-tolerations/pod-without-toleration.yaml
```

4. Testar Pod com toleration compativel:

```bash
kubectl apply -f manifests/10-taints-tolerations/pod-with-toleration.yaml
```

## Comandos de validacao

```bash
kubectl taint nodes <node> dedicated=resilience:NoSchedule
kubectl describe node <node>
kubectl describe pod pod-without-toleration -n resilience-scheduling
kubectl describe pod pod-with-toleration -n resilience-scheduling
kubectl get events -n resilience-scheduling --sort-by=.metadata.creationTimestamp
```

## Limpeza do taint e recursos

```bash
./scripts/remove-dedicated-node-taint.sh
kubectl delete -f manifests/10-taints-tolerations/ --ignore-not-found
```
