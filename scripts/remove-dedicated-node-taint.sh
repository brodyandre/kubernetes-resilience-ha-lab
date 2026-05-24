#!/usr/bin/env bash
set -euo pipefail

# Remove taint dedicated=resilience:NoSchedule e label dedicated=resilience dos nodes.
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

mapfile -t labeled_nodes < <(kubectl get nodes -l "${LABEL_KEY}=${LABEL_VALUE}" -o name | sed 's|node/||')

if [[ ${#labeled_nodes[@]} -eq 0 ]]; then
  warn "Nenhum node com label ${LABEL_KEY}=${LABEL_VALUE} encontrado."
  info "Ainda assim, voce pode remover o taint manualmente por node com:"
  printf '  %s\n' "kubectl taint nodes <node> ${TAINT_KEY}:${TAINT_EFFECT}-"
  exit 0
fi

info "Removendo taint e label dos nodes dedicados..."
for node in "${labeled_nodes[@]}"; do
  untaint_cmd="kubectl taint nodes ${node} ${TAINT_KEY}:${TAINT_EFFECT}-"
  unlabel_cmd="kubectl label node ${node} ${LABEL_KEY}-"

  printf '  %s\n' "${untaint_cmd}"
  printf '  %s\n' "${unlabel_cmd}"

  kubectl taint nodes "${node}" "${TAINT_KEY}:${TAINT_EFFECT}-" || true
  kubectl label node "${node}" "${LABEL_KEY}-" || true
done

info "Estado atual dos nodes:"
kubectl get nodes --show-labels
