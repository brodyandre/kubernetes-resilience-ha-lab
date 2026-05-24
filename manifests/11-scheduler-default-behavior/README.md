# Modulo 11 - Scheduler Default Behavior

## Objetivo

Demonstrar o comportamento padrao de agendamento do Kubernetes quando nao existem restricoes explicitas no Pod.

## Como o scheduler se comporta sem restricoes

Sem `nodeSelector`, sem affinity e sem tolerations customizadas, o Kubernetes Scheduler escolhe o node que considera mais adequado entre os elegiveis.

## O que o scheduler considera

Na decisao de agendamento, o scheduler avalia combinacao de fatores como:

- recursos disponiveis no node
- restricoes definidas no workload
- labels e seletores
- taints e tolerations
- regras de afinidade/anti-affinidade
- estado geral do cluster

## Taints automaticos do Kubernetes

Em situacoes de saude do node, o proprio Kubernetes pode aplicar taints automaticamente (por exemplo, quando um node fica `NotReady` ou indisponivel).  
Esses taints influenciam o agendamento mesmo que o workload nao tenha regras customizadas.

## Manifests do modulo

- `namespace.yaml`
- `deployment-default-scheduling.yaml`

## Execucao

```bash
kubectl apply -f manifests/11-scheduler-default-behavior/
```

## Comandos de validacao

```bash
kubectl get pods -n resilience-scheduling -o wide
kubectl describe pod <nome-do-pod> -n resilience-scheduling
kubectl get events -n resilience-scheduling --sort-by=.metadata.creationTimestamp
kubectl describe node <nome-do-node>
```

## Como interpretar eventos de scheduling

Ao analisar eventos (`kubectl get events` e `kubectl describe pod`), procure por:

- `Scheduled`: indica em qual node o Pod foi alocado
- `FailedScheduling`: mostra por que o scheduler nao conseguiu alocar (falta de recurso, taint nao tolerado, etc.)
- mensagens de preempcao/fit: ajudam a entender decisoes de priorizacao e elegibilidade

Esses eventos sao a principal fonte para diagnosticar comportamento padrao do scheduler em cada cenario.
