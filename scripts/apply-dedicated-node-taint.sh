#!/usr/bin/env bash
set -euo pipefail

# Aplica taint e label de dedicacao em um node worker para o modulo 10.
TAINT_KEY="${TAINT_KEY:-dedicated}"
TAINT_VALUE="${TAINT_VALUE:-resilience}"
TAINT_EFFECT="${TAINT_EFFECT:-NoSchedule}"
LABEL_KEY="${LABEL_KEY:-dedicated}"
LABEL_VALUE="${LABEL_VALUE:-resilience}"

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

info "Nodes disponiveis no cluster:"
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
  warn "Worker nao identificado por nome. Usando primeiro node: ${target_node}"
fi

taint_cmd="kubectl taint nodes ${target_node} ${TAINT_KEY}=${TAINT_VALUE}:${TAINT_EFFECT} --overwrite"
label_cmd="kubectl label node ${target_node} ${LABEL_KEY}=${LABEL_VALUE} --overwrite"

info "Comandos executados:"
printf '  %s\n' "${taint_cmd}"
printf '  %s\n' "${label_cmd}"

kubectl taint nodes "${target_node}" "${TAINT_KEY}=${TAINT_VALUE}:${TAINT_EFFECT}" --overwrite
kubectl label node "${target_node}" "${LABEL_KEY}=${LABEL_VALUE}" --overwrite

info "Resumo do node apos configuracao:"
kubectl describe node "${target_node}" | sed -n '/Taints:/,/Unschedulable:/p'

info "Labels atuais dos nodes:"
kubectl get nodes --show-labels
