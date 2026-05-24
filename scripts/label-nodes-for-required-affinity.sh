#!/usr/bin/env bash
set -euo pipefail

# Aplica disk=ssd em um node worker para teste de Node Affinity obrigatoria.
LABEL_KEY="${LABEL_KEY:-disk}"
LABEL_VALUE="${LABEL_VALUE:-ssd}"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Comando obrigatorio nao encontrado: $1"
    exit 1
  fi
}

require_cmd kubectl

info "Nodes disponiveis:"
kubectl get nodes -o wide

mapfile -t all_nodes < <(kubectl get nodes -o name | sed 's|node/||')
if [[ ${#all_nodes[@]} -eq 0 ]]; then
  error "Nenhum node encontrado."
  exit 1
fi

mapfile -t worker_nodes < <(
  printf '%s\n' "${all_nodes[@]}" | awk '
    {
      lower=tolower($0)
      if (lower !~ /(master|control-plane|server)/) print $0
    }'
)

if [[ ${#worker_nodes[@]} -gt 0 ]]; then
  target_node="${worker_nodes[0]}"
  info "Node worker selecionado automaticamente: ${target_node}"
else
  target_node="${all_nodes[0]}"
  warn "Worker nao identificado por nome. Usando o primeiro node: ${target_node}"
fi

cmd="kubectl label node ${target_node} ${LABEL_KEY}=${LABEL_VALUE} --overwrite"
info "Comando de label:"
printf '  %s\n' "${cmd}"

kubectl label node "${target_node}" "${LABEL_KEY}=${LABEL_VALUE}" --overwrite

info "Labels atuais dos nodes:"
kubectl get nodes --show-labels
