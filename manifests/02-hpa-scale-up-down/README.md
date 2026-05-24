# Modulo 02 - HPA Scale Up e Scale Down

## Objetivo

Demonstrar na pratica o comportamento de aumento e reducao de replicas com Horizontal Pod Autoscaler (HPA).

## Conceito em linguagem simples

O HPA monitora metricas (como CPU) e ajusta a quantidade de Pods automaticamente:

- Scale Up: quando a utilizacao sobe acima da meta, o HPA aumenta replicas.
- Scale Down: quando a utilizacao cai, o HPA reduz replicas ate o minimo configurado.

## Scale Up

Neste modulo, o HPA monitora CPU com alvo de 50%.  
Quando o gerador de carga envia chamadas HTTP continuas, o consumo de CPU tende a subir e o HPA pode aumentar o numero de Pods do Deployment `hpa-scale-app`.

## Scale Down

Ao parar a carga, o consumo de CPU tende a cair e o HPA pode reduzir replicas.  
Esse processo nao costuma ser imediato: o HPA possui comportamento de estabilizacao para evitar oscilacoes rapidas.

## Manifests do modulo

- `namespace.yaml`
- `deployment.yaml`
- `service.yaml`
- `hpa.yaml`
- `load-generator.yaml`

## Como iniciar o teste

```bash
kubectl apply -f manifests/02-hpa-scale-up-down/
```

Ou, com script de apoio:

```bash
./scripts/run-hpa-load-test.sh
```

## Como parar a carga

```bash
kubectl delete -f manifests/02-hpa-scale-up-down/load-generator.yaml --ignore-not-found
```

## Comandos de validacao

```bash
kubectl get hpa -n resilience-hpa
kubectl describe hpa hpa-scale-app -n resilience-hpa
kubectl get pods -n resilience-hpa -o wide
kubectl get deployment hpa-scale-app -n resilience-hpa
kubectl get events -n resilience-hpa --sort-by=.metadata.creationTimestamp
```

Observacao em tempo real:

```bash
./scripts/watch-hpa.sh
```

## Possiveis problemas

1. `metrics-server` indisponivel:
- Sintoma: `TARGETS` do HPA fica `unknown`.
- Acao: verificar instalacao e status do Metrics Server.

2. Sem carga suficiente:
- Sintoma: replicas nao aumentam.
- Acao: confirmar se `load-generator.yaml` esta em execucao.

3. Scale down aparentemente lento:
- Sintoma: replicas demoram a reduzir apos remover carga.
- Acao: aguardar janela de estabilizacao do HPA e acompanhar eventos.

## Evidencia recomendada

Adicionar manualmente em `evidence/`:

1. Screenshot do `kubectl get hpa -n resilience-hpa` durante scale up.
2. Screenshot do `kubectl get pods -n resilience-hpa -o wide` mostrando mais replicas.
3. Screenshot apos remover carga, mostrando reducao gradual de replicas.
4. Log de `kubectl describe hpa hpa-scale-app -n resilience-hpa`.
