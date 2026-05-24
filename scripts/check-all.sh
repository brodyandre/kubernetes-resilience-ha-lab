#!/usr/bin/env bash
set -euo pipefail

# Faz validacao operacional dos principais recursos do laboratorio.
LAB_NAMESPACES="${LAB_NAMESPACES:-resilience-hpa resilience-scheduling}"

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

info "Contexto atual:"
kubectl config current-context

info "Pods (all namespaces):"
kubectl get pods -A -o wide

info "Deployments (all namespaces):"
kubectl get deployments -A

info "Services (all namespaces):"
kubectl get services -A

info "HPA (all namespaces):"
kubectl get hpa -A

info "Labels dos nodes:"
kubectl get nodes --show-labels

info "Taints dos nodes:"
kubectl get nodes -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'

found_namespace=false
for namespace in ${LAB_NAMESPACES}; do
  if kubectl get namespace "${namespace}" >/dev/null 2>&1; then
    found_namespace=true
    info "Eventos relevantes no namespace ${namespace}:"
    kubectl get events -n "${namespace}" --sort-by=.metadata.creationTimestamp
  else
    warn "Namespace ${namespace} nao encontrado."
  fi
done

if [[ "${found_namespace}" == false ]]; then
  warn "Nenhum namespace esperado foi encontrado. Exibindo ultimos eventos globais."
  kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -n 50
fi

info "Verificacao concluida."
