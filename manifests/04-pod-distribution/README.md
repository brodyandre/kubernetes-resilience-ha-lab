# Modulo 04 - Pod Distribution

## Objetivo

Demonstrar como o Kubernetes Scheduler distribui Pods entre Nodes e como melhorar essa distribuicao com `topologySpreadConstraints`.

## Como o Scheduler decide

O Scheduler avalia os Nodes elegiveis e escolhe onde cada Pod sera executado com base em recursos disponiveis, regras de afinidade/anti-afinidade, taints/tolerations e politicas de distribuicao.

Sem uma regra explicita de spread, a distribuicao pode ficar menos equilibrada dependendo do estado do cluster no momento do agendamento.

## Por que distribuir Pods melhora disponibilidade

Quando replicas ficam concentradas em poucos Nodes, uma falha de Node pode derrubar varias replicas ao mesmo tempo.  
Com distribuicao mais uniforme, o impacto de falha de um unico Node tende a ser menor.

## Escolha de `whenUnsatisfiable`

Neste modulo foi usado `whenUnsatisfiable: ScheduleAnyway`.

Motivo: em laboratorio local (k3d/kind), isso evita Pods pendentes em cenarios com restricao temporaria de recursos e ainda orienta o Scheduler a priorizar a reducao de skew (`maxSkew: 1`).

Em ambientes de producao mais restritivos, `DoNotSchedule` pode ser preferivel quando se deseja regra estrita de distribuicao.

## Manifests

- `namespace.yaml`
- `deployment-basic.yaml`
- `deployment-with-topology-spread.yaml`

## Como comparar antes e depois

1. Aplicar namespace e deployment basico:

```bash
kubectl apply -f manifests/04-pod-distribution/namespace.yaml
kubectl apply -f manifests/04-pod-distribution/deployment-basic.yaml
kubectl get pods -n resilience-scheduling -o wide
kubectl describe deployment distribution-basic -n resilience-scheduling
```

2. Remover deployment basico e aplicar a versao com topology spread:

```bash
kubectl delete -f manifests/04-pod-distribution/deployment-basic.yaml --ignore-not-found
kubectl apply -f manifests/04-pod-distribution/deployment-with-topology-spread.yaml
kubectl get pods -n resilience-scheduling -o wide
kubectl describe deployment distribution-topology-spread -n resilience-scheduling
```

3. Comparar:

- quantidade de Pods por Node no cenario basico
- quantidade de Pods por Node com `topologySpreadConstraints`
- diferenca de equilibrio entre os Nodes
