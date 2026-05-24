# Evidence

Esta pasta armazena evidencias reais de execucao do laboratorio.

## Regra obrigatoria

Nao crie evidencias falsas.  
Nao simule resultados.  
Somente salve outputs reais coletados apos executar os modulos.

## O que salvar

1. Logs e outputs reais em arquivos `.txt` dentro de `evidence/logs/`.
2. Screenshots (opcional) dentro de `evidence/screenshots/`.

## Estrutura recomendada

```text
evidence/
|-- README.md
|-- logs/
`-- screenshots/
```

## Evidencias recomendadas

1. Cluster criado com 3 workers:
- `kubectl get nodes -o wide`

2. Metrics Server funcionando:
- `kubectl top nodes`
- `kubectl top pods -A`

3. HPA basico:
- `kubectl get hpa -n resilience-hpa`
- `kubectl describe hpa hpa-basic-app -n resilience-hpa`

4. Scale Up:
- `kubectl get hpa,pods -n resilience-hpa`

5. Scale Down:
- mesmo comando apos reduzir/remover a carga

6. HPA por container:
- `kubectl describe hpa -n resilience-hpa`

7. Distribuicao de Pods:
- `kubectl get pods -n resilience-scheduling -o wide`

8. Labels em Nodes:
- `kubectl get nodes --show-labels`

9. Node Affinity:
- `kubectl describe pod -n resilience-scheduling`

10. Pod Affinity e Anti-Affinity:
- `kubectl get pods -n resilience-scheduling -o wide`

11. Taints e Tolerations:
- `kubectl describe node`
- `kubectl describe pod`
- `kubectl get events -n resilience-scheduling`

## Guia completo

Para padrao de nomes de arquivos, checklist de qualidade e fluxo de coleta, veja:

- [docs/EVIDENCE_GUIDE.md](../docs/EVIDENCE_GUIDE.md)
