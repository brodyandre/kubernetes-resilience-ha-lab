# Manifests

Esta pasta centraliza os manifests Kubernetes do laboratorio.

## Objetivo

Demonstrar, de forma incremental, como diferentes configuracoes de scheduling e autoscaling afetam resiliencia e disponibilidade.

## Estrutura Sugerida

```text
manifests/
|-- 00-namespace/
|-- 10-workload-base/
|-- 20-hpa/
|-- 30-node-placement/
|-- 40-affinity/
`-- 50-taints-tolerations/
```

## Padroes Minimos

1. Nomear arquivos com prefixo numerico para manter ordem de leitura.
2. Incluir `metadata.labels` consistentes entre recursos.
3. Definir `resources.requests` e `resources.limits` para cenarios com HPA.
4. Documentar finalidade do manifesto no inicio do arquivo.
