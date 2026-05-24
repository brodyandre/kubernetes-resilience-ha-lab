# Modulo 01 - HPA Basic

## Objetivo

Demonstrar o primeiro exemplo de Horizontal Pod Autoscaler (HPA) em Kubernetes, usando metrica de CPU para ajustar a quantidade de replicas automaticamente.

## O que e HPA (explicacao simples)

HPA e um recurso do Kubernetes que aumenta ou reduz o numero de Pods de um Deployment com base em metricas, como uso de CPU.  
Quando a carga sobe, ele pode criar mais replicas. Quando a carga cai, ele pode reduzir replicas para economizar recursos.

## Por que requests de CPU sao importantes

Para calcular `averageUtilization`, o HPA compara o consumo atual de CPU com o valor de `requests.cpu` definido no container.  
Sem `requests.cpu`, o HPA de CPU nao consegue calcular corretamente a utilizacao e pode nao escalar.

## Manifests deste modulo

- `namespace.yaml`
- `deployment.yaml`
- `service.yaml`
- `hpa.yaml`

## Comandos de execucao

```bash
kubectl apply -f manifests/01-hpa-basic/
kubectl get hpa -n resilience-hpa
kubectl describe hpa hpa-basic-app -n resilience-hpa
kubectl get pods -n resilience-hpa -o wide
```

## Resultado esperado

- Namespace `resilience-hpa` criado.
- Deployment `hpa-basic-app` com 1 replica inicial.
- Service `ClusterIP` criado e apontando para os Pods.
- HPA `hpa-basic-app` com `minReplicas: 1` e `maxReplicas: 5`.
- Com carga de CPU, o numero de replicas pode aumentar; sem carga, tende a voltar para o minimo.

## Possiveis problemas

1. `metrics-server` indisponivel:
- Sintoma: `kubectl get hpa` mostra metrica como `unknown` ou nao atualiza.
- Acao: validar se o Metrics Server esta instalado e pronto.

2. Sem `requests.cpu` no Deployment:
- Sintoma: HPA nao calcula utilizacao de CPU corretamente.
- Acao: confirmar `resources.requests.cpu` no container.

3. Cluster sem carga suficiente:
- Sintoma: replicas nao aumentam.
- Acao: gerar carga HTTP/CPU para observar scale up.
