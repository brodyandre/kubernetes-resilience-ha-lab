#!/usr/bin/env bash
set -euo pipefail

# Exibe saude basica do cluster e disponibilidade de metricas.
LAB_NAMESPACE_PATTERN="${LAB_NAMESPACE_PATTERN:-resilience-hpa|resilience-scheduling}"

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

info "Contexto kubectl atual:"
kubectl config current-context

info "Nodes do cluster:"
kubectl get nodes -o wide

info "Namespaces do laboratorio (filtro: ${LAB_NAMESPACE_PATTERN}):"
lab_namespaces="$(kubectl get namespaces --no-headers | awk -v pattern="${LAB_NAMESPACE_PATTERN}" '$1 ~ pattern {print $0}')"
if [[ -n "${lab_namespaces}" ]]; then
  printf 'NAME\tSTATUS\tAGE\n'
  printf '%s\n' "${lab_namespaces}"
else
  warn "Nenhum namespace do laboratorio encontrado com o filtro atual."
fi

info "Status da Metrics API:"
if kubectl get apiservice v1beta1.metrics.k8s.io >/dev/null 2>&1; then
  kubectl get apiservice v1beta1.metrics.k8s.io
  if kubectl get --raw /apis/metrics.k8s.io/v1beta1 >/dev/null 2>&1; then
    info "API metrics.k8s.io/v1beta1 respondendo."
  else
    warn "API metrics.k8s.io registrada, mas ainda sem resposta."
  fi
else
  warn "Metrics API nao disponivel."
fi
