# Scripts

Automacoes de suporte para o laboratorio.

## Scripts Disponiveis

- `setup-cluster-k3d.sh`: cria/reutiliza cluster `resilience-ha-lab` no k3d.
- `install-metrics-server.sh`: instala o Metrics Server com ajustes para ambiente local.
- `check-cluster.sh`: checagem rapida de contexto, nodes, namespaces e metrics API.
- `apply-all.sh`: aplica manifests na ordem modular recomendada.
- `check-all.sh`: valida recursos Kubernetes, labels, taints e eventos.
- `cleanup-all.sh`: remove recursos do laboratorio e preserva o cluster por padrao.
- `capture-evidence.sh`: gera `.txt` reais de evidencias em `evidence/logs/`.
- `generate-readme-screenshots.sh`: gera os PNGs usados no `README.md` a partir das saidas reais do cluster.
- `render-terminal-screenshot.py`: renderiza capturas estilo terminal em PNG para o fluxo de evidencias visuais.
- `run-hpa-load-test.sh`: aplica modulo 02 e inicia carga para validar scale up/down.
- `watch-hpa.sh`: observa HPA e Pods em tempo real no namespace `resilience-hpa`.
- `label-nodes-for-node-selector.sh`: identifica um worker e aplica `workload=resilience`.
- `remove-node-selector-labels.sh`: remove labels aplicadas para o modulo de nodeSelector.
- `label-nodes-for-required-affinity.sh`: aplica `disk=ssd` para teste de affinity obrigatoria.
- `remove-required-affinity-labels.sh`: remove labels `disk` usadas no modulo 06.
- `label-nodes-for-preferred-affinity.sh`: aplica `zone=preferred` para teste de affinity preferencial.
- `remove-preferred-affinity-labels.sh`: remove labels `zone` usadas no modulo 07.
- `apply-dedicated-node-taint.sh`: aplica taint `dedicated=resilience:NoSchedule` e label dedicada.
- `remove-dedicated-node-taint.sh`: remove taint/label dedicados usados no modulo 10.

## Convencoes

1. Scripts devem ser idempotentes sempre que possivel.
2. Todo script deve ter comentario de uso no topo.
3. Evitar defaults destrutivos sem confirmacao explicita.
4. Quando gerar arquivos, salvar em `evidence/logs/` ou pasta documentada.
