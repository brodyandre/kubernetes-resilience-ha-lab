# Modulo 09 - Pod Affinity

## Objetivo

Demonstrar Pod Affinity para aproximar workloads que se beneficiam de baixa latencia e dependencia local entre componentes.

## O que e Pod Affinity

Pod Affinity e uma regra de scheduling que incentiva (ou exige) que Pods sejam agendados proximos de outros Pods com labels especificas.

Neste modulo, `app-near-cache` prefere ser agendado no mesmo `kubernetes.io/hostname` de Pods `app=cache-service`.

## Aproximar Pods vs espalhar Pods

- Aproximar Pods (Affinity): reduz distancia de comunicacao entre componentes que colaboram diretamente.
- Espalhar Pods (Anti-Affinity/Spread): reduz concentracao para aumentar resiliencia contra falha de node.

As duas estrategias nao competem; elas atendem objetivos diferentes e podem ser combinadas.

## Casos reais de uso

1. Cache:
- aplicacao e cache no mesmo node podem reduzir latencia e trafego de rede.

2. Baixa latencia:
- servicos com chamadas muito frequentes ganham desempenho com co-localizacao.

3. Processamento acoplado:
- etapas de pipeline que trocam dados intensivamente se beneficiam de proximidade.

## Manifests

- `namespace.yaml`
- `cache-deployment.yaml`
- `app-with-pod-affinity.yaml`

## Execucao

```bash
kubectl apply -f manifests/09-pod-affinity/
```

## Validacao

```bash
kubectl get pods -n resilience-scheduling -o wide
kubectl describe pod <nome-do-pod> -n resilience-scheduling
```

Analise recomendada:

- verificar em quais nodes os Pods `cache-service` foram agendados
- verificar se os Pods `app-near-cache` tendem a ir para os mesmos nodes quando ha capacidade
