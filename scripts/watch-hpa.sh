#!/usr/bin/env bash
set -euo pipefail

# Observe o aumento e a reducao de replicas do HPA enquanto a carga sobe e desce.
NAMESPACE="${NAMESPACE:-resilience-hpa}"

info() { printf '[INFO] %s\n' "$*"; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Comando obrigatorio nao encontrado: $1"
    exit 1
  fi
}

require_cmd kubectl

if command -v watch >/dev/null 2>&1; then
  info "Abrindo watch para HPA e Pods no namespace ${NAMESPACE}."
  watch -n 2 "kubectl get hpa,pods -n ${NAMESPACE}"
else
  info "Comando watch nao encontrado. Usando loop de observacao a cada 2 segundos."
  while true; do
    clear
    date
    kubectl get hpa,pods -n "${NAMESPACE}"
    sleep 2
  done
fi
