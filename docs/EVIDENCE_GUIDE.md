# Evidence Guide

Guia oficial de coleta de evidencias do laboratorio `kubernetes-resilience-ha-lab`.

## Principios

1. Coletar somente outputs reais.
2. Nao inventar logs, prints ou resultados.
3. Registrar evidencias no momento da execucao do cenario.
4. Manter arquivos com nomes claros e rastreaveis.

## Onde salvar

- Logs e saidas de comandos: `evidence/logs/*.txt`
- Capturas de tela (opcional): `evidence/screenshots/*`

## Padrao sugerido de nomes

Use prefixo numerico para facilitar revisao:

- `01-cluster-nodes.txt`
- `02-metrics-top-nodes.txt`
- `03-hpa-basic-get.txt`
- `04-scale-up.txt`
- `05-scale-down.txt`

## Evidencias recomendadas por tema

### 1. Cluster criado com 3 workers

- Comando:
  - `kubectl get nodes -o wide`
- Salvar em:
  - `evidence/logs/01-cluster-nodes.txt`

### 2. Metrics Server funcionando

- Comandos:
  - `kubectl top nodes`
  - `kubectl top pods -A`
- Salvar em:
  - `evidence/logs/02-metrics-top-nodes.txt`
  - `evidence/logs/02-metrics-top-pods-all.txt`

### 3. HPA basico

- Comandos:
  - `kubectl get hpa -n resilience-hpa`
  - `kubectl describe hpa hpa-basic-app -n resilience-hpa`
- Salvar em:
  - `evidence/logs/03-hpa-basic-get.txt`
  - `evidence/logs/03-hpa-basic-describe.txt`

### 4. Scale Up

- Comando:
  - `kubectl get hpa,pods -n resilience-hpa`
- Salvar em:
  - `evidence/logs/04-scale-up.txt`

### 5. Scale Down

- Comando:
  - `kubectl get hpa,pods -n resilience-hpa` (apos reduzir/remover carga)
- Salvar em:
  - `evidence/logs/05-scale-down.txt`

### 6. HPA por container

- Comando:
  - `kubectl describe hpa -n resilience-hpa`
- Salvar em:
  - `evidence/logs/06-hpa-container-describe.txt`

### 7. Distribuicao de Pods

- Comando:
  - `kubectl get pods -n resilience-scheduling -o wide`
- Salvar em:
  - `evidence/logs/07-pod-distribution-wide.txt`

### 8. Labels em Nodes

- Comando:
  - `kubectl get nodes --show-labels`
- Salvar em:
  - `evidence/logs/08-node-labels.txt`

### 9. Node Affinity

- Comando:
  - `kubectl describe pod -n resilience-scheduling`
- Salvar em:
  - `evidence/logs/09-node-affinity-describe-pod.txt`

### 10. Pod Affinity e Anti-Affinity

- Comando:
  - `kubectl get pods -n resilience-scheduling -o wide`
- Salvar em:
  - `evidence/logs/10-pod-affinity-anti-affinity-wide.txt`

### 11. Taints e Tolerations

- Comandos:
  - `kubectl describe node`
  - `kubectl describe pod`
  - `kubectl get events -n resilience-scheduling`
- Salvar em:
  - `evidence/logs/11-taints-describe-node.txt`
  - `evidence/logs/11-taints-describe-pod.txt`
  - `evidence/logs/11-taints-events.txt`

## Screenshots (opcional)

Se desejar complementar os logs, adicione imagens em `evidence/screenshots/` com foco em:

1. HPA antes/durante/depois da carga.
2. Distribuicao de Pods por node (`-o wide`).
3. Eventos de falha de scheduling (`Pending`, `FailedScheduling`).

## Qualidade minima antes de publicar

1. Confirmar que todos os arquivos representam execucao real.
2. Remover dados sensiveis (IPs publicos, tokens, credenciais, endpoints internos).
3. Garantir que os nomes dos arquivos estao consistentes com o modulo correspondente.
4. Conferir se os comandos usados no texto batem com o conteudo salvo.
