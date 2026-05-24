# Troubleshooting - Kubernetes Resilience HA Lab

Guia de diagnostico para problemas comuns do laboratorio.

## 1. HPA mostra `cpu: <unknown>`

- Sintoma:
  - `kubectl get hpa` exibe `TARGETS` como `cpu: <unknown>`.
- Causa provavel:
  - Metrics Server indisponivel ou sem conseguir coletar metricas.
  - `resources.requests.cpu` ausente no container alvo.
- Comando de diagnostico:

```bash
kubectl get hpa -A
kubectl describe hpa <nome-do-hpa> -n <namespace>
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl describe deployment <nome-do-deployment> -n <namespace>
```

- Solucao sugerida:
  - Instalar/corrigir Metrics Server.
  - Garantir `requests.cpu` no workload monitorado pelo HPA.
- Comando de validacao:

```bash
kubectl get hpa -n <namespace>
kubectl describe hpa <nome-do-hpa> -n <namespace>
```

## 2. `kubectl top nodes` nao funciona

- Sintoma:
  - Erro ao executar `kubectl top nodes` ou retorno vazio.
- Causa provavel:
  - Metrics API indisponivel.
  - Metrics Server ainda inicializando.
- Comando de diagnostico:

```bash
kubectl top nodes
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl -n kube-system get deploy metrics-server
kubectl -n kube-system get pods -l k8s-app=metrics-server
```

- Solucao sugerida:
  - Reinstalar ou ajustar Metrics Server para ambiente local.
  - Aguardar rollout e sincronizacao das metricas.
- Comando de validacao:

```bash
kubectl top nodes
kubectl top pods -A
```

## 3. Metrics Server nao esta disponivel

- Sintoma:
  - `kubectl get apiservice v1beta1.metrics.k8s.io` mostra status `False`.
  - HPA e `kubectl top` falham.
- Causa provavel:
  - Deployment do Metrics Server indisponivel.
  - Problema de comunicacao com kubelet em cluster local.
- Comando de diagnostico:

```bash
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl -n kube-system describe deployment metrics-server
kubectl -n kube-system logs deployment/metrics-server
```

- Solucao sugerida:
  - Executar script do laboratorio:
  - `./scripts/install-metrics-server.sh`
  - Confirmar rollout concluido.
- Comando de validacao:

```bash
kubectl -n kube-system rollout status deployment/metrics-server
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top nodes
```

## 4. Pod fica `Pending`

- Sintoma:
  - Pod nao transiciona para `Running`.
- Causa provavel:
  - Falta de recursos no cluster.
  - Restricoes de scheduling (taint, affinity, nodeSelector).
  - Imagem nao disponivel.
- Comando de diagnostico:

```bash
kubectl get pods -A
kubectl describe pod <nome-do-pod> -n <namespace>
kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp
```

- Solucao sugerida:
  - Ajustar requests/limits ou aumentar capacidade do cluster.
  - Revisar rules de scheduling.
  - Corrigir referencia de imagem.
- Comando de validacao:

```bash
kubectl get pod <nome-do-pod> -n <namespace> -o wide
```

## 5. Pod nao vai para o node esperado

- Sintoma:
  - Pod executa em node diferente do planejado.
- Causa provavel:
  - Label alvo ausente/inconsistente.
  - Preferencia (preferred) em vez de regra obrigatoria (required).
  - Conflito com taints, afinidade, anti-affinity ou recursos.
- Comando de diagnostico:

```bash
kubectl get nodes --show-labels
kubectl describe pod <nome-do-pod> -n <namespace>
kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp
```

- Solucao sugerida:
  - Corrigir labels e seletores.
  - Ajustar tipo de regra de affinity (required vs preferred).
  - Revisar taints/tolerations ativas.
- Comando de validacao:

```bash
kubectl get pods -n <namespace> -o wide
```

## 6. `nodeSelector` nao encontra label

- Sintoma:
  - Pod com `nodeSelector` fica `Pending`.
- Causa provavel:
  - Nenhum node possui o par `key=value` exigido.
- Comando de diagnostico:

```bash
kubectl get nodes --show-labels
kubectl describe pod <nome-do-pod> -n <namespace>
```

- Solucao sugerida:
  - Aplicar label correta no node alvo.
  - Script util no laboratorio:
  - `./scripts/label-nodes-for-node-selector.sh`
- Comando de validacao:

```bash
kubectl get nodes --show-labels
kubectl get pods -n resilience-scheduling -o wide
```

## 7. Node Affinity obrigatoria impede agendamento

- Sintoma:
  - Pods com `requiredDuringSchedulingIgnoredDuringExecution` ficam `Pending`.
- Causa provavel:
  - Nenhum node atende `matchExpressions` da regra obrigatoria.
- Comando de diagnostico:

```bash
kubectl describe pod <nome-do-pod> -n resilience-scheduling
kubectl get nodes --show-labels
kubectl get events -n resilience-scheduling --sort-by=.metadata.creationTimestamp
```

- Solucao sugerida:
  - Aplicar labels exigidas pela affinity obrigatoria.
  - Script util no laboratorio:
  - `./scripts/label-nodes-for-required-affinity.sh`
- Comando de validacao:

```bash
kubectl get pods -n resilience-scheduling -o wide
```

## 8. Anti-Affinity nao espalha Pods como esperado

- Sintoma:
  - Mesmo com anti-affinity, replicas aparecem juntas em alguns nodes.
- Causa provavel:
  - Regra configurada como `preferred` (nao obrigatoria).
  - Cluster local com poucos nodes/capacidade limitada.
- Comando de diagnostico:

```bash
kubectl get pods -n resilience-scheduling -o wide
kubectl describe deployment app-with-anti-affinity -n resilience-scheduling
kubectl describe pod <nome-do-pod> -n resilience-scheduling
```

- Solucao sugerida:
  - Entender que `preferred` prioriza, mas nao bloqueia.
  - Para regra estrita, avaliar `required` (com cautela em cluster local).
  - Aumentar quantidade de nodes se necessario.
- Comando de validacao:

```bash
kubectl get pods -n resilience-scheduling -o wide
```

## 9. Taint bloqueia Pod

- Sintoma:
  - Pod fica `Pending` com eventos indicando taint nao tolerado.
- Causa provavel:
  - Node possui taint `NoSchedule` sem toleration compativel no Pod.
- Comando de diagnostico:

```bash
kubectl describe node <nome-do-node>
kubectl describe pod <nome-do-pod> -n resilience-scheduling
kubectl get events -n resilience-scheduling --sort-by=.metadata.creationTimestamp
```

- Solucao sugerida:
  - Adicionar toleration compativel no Pod.
  - Ou remover/ajustar taint do node quando apropriado.
- Comando de validacao:

```bash
kubectl get pods -n resilience-scheduling -o wide
```

## 10. Toleration existe, mas o Pod ainda nao agenda

- Sintoma:
  - Pod continua `Pending` mesmo com toleration.
- Causa provavel:
  - Toleration com chave/valor/efeito diferente do taint real.
  - NodeSelector/Affinity restringindo demais.
  - Falta de recursos no node tolerado.
- Comando de diagnostico:

```bash
kubectl describe pod <nome-do-pod> -n resilience-scheduling
kubectl describe node <nome-do-node>
kubectl get nodes --show-labels
kubectl get events -n resilience-scheduling --sort-by=.metadata.creationTimestamp
```

- Solucao sugerida:
  - Alinhar toleration com taint (`key`, `value`, `effect`).
  - Revisar nodeSelector e affinity em conjunto.
  - Verificar capacidade do node.
- Comando de validacao:

```bash
kubectl get pod <nome-do-pod> -n resilience-scheduling -o wide
```

## 11. Cluster local tem poucos nodes

- Sintoma:
  - Regras de spread/affinity nao mostram efeito esperado.
  - Pods pendentes em cenarios mais restritivos.
- Causa provavel:
  - Topologia local insuficiente para atender restricoes.
- Comando de diagnostico:

```bash
kubectl get nodes -o wide
kubectl get pods -A -o wide
```

- Solucao sugerida:
  - Recriar cluster com mais workers.
  - Exemplo com script do laboratorio:
  - `./scripts/setup-cluster-k3d.sh` (padrao 1 server + 3 agents).
- Comando de validacao:

```bash
kubectl get nodes -o wide
```

## 12. Imagem nao baixa (`ImagePullBackOff`)

- Sintoma:
  - Pod com status `ImagePullBackOff` ou `ErrImagePull`.
- Causa provavel:
  - Nome/tag da imagem incorretos.
  - Problema de conectividade com registry.
  - Rate limit/autenticacao do registry.
- Comando de diagnostico:

```bash
kubectl describe pod <nome-do-pod> -n <namespace>
kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp
```

- Solucao sugerida:
  - Corrigir imagem/tag.
  - Testar pull manual no ambiente local.
  - Usar imagem publica acessivel no contexto do cluster.
- Comando de validacao:

```bash
kubectl get pod <nome-do-pod> -n <namespace>
```

## 13. Como limpar labels e taints de nodes

- Sintoma:
  - Cenarios anteriores continuam interferindo no agendamento atual.
- Causa provavel:
  - Labels e taints de experimentos anteriores nao foram removidos.
- Comando de diagnostico:

```bash
kubectl get nodes --show-labels
kubectl describe node <nome-do-node>
```

- Solucao sugerida:
  - Usar scripts de limpeza do laboratorio:
  - `./scripts/remove-node-selector-labels.sh`
  - `./scripts/remove-required-affinity-labels.sh`
  - `./scripts/remove-preferred-affinity-labels.sh`
  - `./scripts/remove-dedicated-node-taint.sh`
  - Ou limpar manualmente:
  - `kubectl label node <node> workload-`
  - `kubectl label node <node> disk-`
  - `kubectl label node <node> zone-`
  - `kubectl label node <node> dedicated-`
  - `kubectl taint nodes <node> dedicated:NoSchedule-`
- Comando de validacao:

```bash
kubectl get nodes --show-labels
kubectl describe node <nome-do-node>
```
