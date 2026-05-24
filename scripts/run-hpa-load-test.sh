#!/usr/bin/env bash
set -euo pipefail

# Aplica o modulo de scale up/down e inicia carga HTTP continua para observar HPA.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MODULE_DIR="${MODULE_DIR:-${REPO_ROOT}/manifests/02-hpa-scale-up-down}"
NAMESPACE="${NAMESPACE:-resilience-hpa}"

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

if [[ ! -d "${MODULE_DIR}" ]]; then
  error "Diretorio do modulo nao encontrado: ${MODULE_DIR}"
  exit 1
fi

info "Aplicando manifests do modulo 02 (sem iniciar carga ainda)..."
kubectl apply -f "${MODULE_DIR}/namespace.yaml"
kubectl apply -f "${MODULE_DIR}/deployment.yaml"
kubectl apply -f "${MODULE_DIR}/service.yaml"
kubectl apply -f "${MODULE_DIR}/hpa.yaml"

info "Aguardando deployment hpa-scale-app ficar pronto..."
kubectl -n "${NAMESPACE}" rollout status deployment/hpa-scale-app --timeout=180s

info "Iniciando gerador de carga..."
kubectl apply -f "${MODULE_DIR}/load-generator.yaml"

info "Comandos para observacao:"
printf '  %s\n' "kubectl get hpa -n ${NAMESPACE} -w"
printf '  %s\n' "kubectl get pods -n ${NAMESPACE} -w"
printf '  %s\n' "./scripts/watch-hpa.sh"
printf '  %s\n' "kubectl describe hpa hpa-scale-app -n ${NAMESPACE}"

warn "Para parar a carga, execute:"
printf '  %s\n' "kubectl delete -f ${MODULE_DIR}/load-generator.yaml --ignore-not-found"
