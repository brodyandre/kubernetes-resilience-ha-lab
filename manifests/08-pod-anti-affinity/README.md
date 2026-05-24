# Modulo 08 - Pod Anti-Affinity

## Objetivo

Demonstrar como usar Pod Anti-Affinity para reduzir concentracao de replicas criticas no mesmo Node.

## Problema de concentracao

Sem restricoes de distribuicao, o scheduler pode colocar varias replicas no mesmo node.  
Se esse node falhar, varias replicas ficam indisponiveis ao mesmo tempo, reduzindo resiliencia.

## Como anti-affinity melhora resiliencia

Com Pod Anti-Affinity, o scheduler passa a evitar (ou impedir, dependendo da regra) que Pods equivalentes fiquem juntos no mesmo dominio de topologia.

Neste modulo, usamos:

- `topologyKey: kubernetes.io/hostname`
- `preferredDuringSchedulingIgnoredDuringExecution`

A escolha por regra preferencial facilita execucao em cluster local, onde quantidade de nodes e capacidade podem ser limitadas.

## Manifests

- `namespace.yaml`
- `deployment-without-anti-affinity.yaml`
- `deployment-with-anti-affinity.yaml`

## Comparacao pratica

1. Aplicar namespace e deployment sem anti-affinity:

```bash
kubectl apply -f manifests/08-pod-anti-affinity/namespace.yaml
kubectl apply -f manifests/08-pod-anti-affinity/deployment-without-anti-affinity.yaml
kubectl get pods -n resilience-scheduling -o wide
```

2. Remover deployment sem anti-affinity e aplicar deployment com anti-affinity:

```bash
kubectl delete -f manifests/08-pod-anti-affinity/deployment-without-anti-affinity.yaml --ignore-not-found
kubectl apply -f manifests/08-pod-anti-affinity/deployment-with-anti-affinity.yaml
kubectl get pods -n resilience-scheduling -o wide
```

3. Comparar em quais nodes as replicas foram alocadas.

## Resultado esperado

- Sem anti-affinity: maior chance de concentracao de replicas no mesmo node.
- Com anti-affinity preferencial: tendencia de distribuicao melhor entre nodes distintos, respeitando capacidade real do cluster.

## Uso em ambiente real

Em workloads criticos, Pod Anti-Affinity reduz risco de indisponibilidade por falha de node.  
Em producao, e comum combinar:

- anti-affinity por node (`kubernetes.io/hostname`)
- spread por zona (`topology.kubernetes.io/zone`)
- HPA e probes de saude

Essa combinacao melhora continuidade de servico durante falhas e durante eventos de reescalonamento.
