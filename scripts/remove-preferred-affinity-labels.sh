#!/usr/bin/env bash
set -euo pipefail

# Remove o label zone=preferred dos nodes usados no modulo de Node Affinity preferencial.
LABEL_KEY="${LABEL_KEY:-zone}"
LABEL_VALUE="${LABEL_VALUE:-preferred}"

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
  info "Estado atual dos nodes:"
  kubectl get nodes --show-labels
  exit 0
fi

info "Removendo label ${LABEL_KEY} dos nodes selecionados..."
for node in "${labeled_nodes[@]}"; do
  cmd="kubectl label node ${node} ${LABEL_KEY}-"
  printf '  %s\n' "${cmd}"
  kubectl label node "${node}" "${LABEL_KEY}-"
done

info "Labels apos limpeza:"
kubectl get nodes --show-labels
