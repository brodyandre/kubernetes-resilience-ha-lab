# Modulo 03 - HPA com Metricas por Container

## Objetivo

Demonstrar autoscaling com HPA usando metrica de um container especifico (`ContainerResource`) em um Pod que possui mais de um container.

## Conceito: Pod inteiro vs container especifico

- Metrica de Pod inteiro (`type: Resource`): o HPA considera o consumo agregado dos containers relevantes do Pod.
- Metrica por container (`type: ContainerResource`): o HPA observa somente o container definido na metrica.

Neste modulo, o alvo e o container `application`.

## Por que isso e util quando existe sidecar

Quando um Pod tem sidecar (proxy, log collector, agent etc.), o sidecar pode consumir CPU de forma diferente da aplicacao principal.  
Se o HPA escalar com metrica agregada, esse consumo pode distorcer a decisao de escala.  
Com `ContainerResource`, voce escala baseado apenas no container que representa a carga real da aplicacao.

## Manifests do modulo

- `namespace.yaml`
- `deployment.yaml`
- `service.yaml`
- `hpa-container-resource.yaml`

## Comandos de execucao

```bash
kubectl apply -f manifests/03-hpa-container-metrics/
```

## Comandos de validacao

```bash
kubectl get hpa -n resilience-hpa
kubectl describe hpa hpa-container-app -n resilience-hpa
kubectl get deployment hpa-container-app -n resilience-hpa
kubectl get pods -n resilience-hpa -o wide
kubectl describe deployment hpa-container-app -n resilience-hpa
```

## Resultado esperado

- Deployment `hpa-container-app` com 2 containers por Pod (`application` e `sidecar`).
- HPA em `autoscaling/v2` configurado com `ContainerResource` para CPU do container `application`.
- Ajuste de replicas entre 1 e 5 conforme a utilizacao do container alvo.

## Troubleshooting

1. `TARGETS` em `unknown` no HPA:
- Verificar se o Metrics Server esta disponivel.
- Confirmar que a API `metrics.k8s.io` responde.

2. HPA nao escala:
- Confirmar se existe carga suficiente no container `application`.
- Verificar se `resources.requests.cpu` esta definido no container alvo.

3. Erro de nome de container no HPA:
- O campo `containerResource.container` deve ser exatamente `application`.
- Conferir nomes reais em `kubectl get deploy hpa-container-app -n resilience-hpa -o yaml`.
