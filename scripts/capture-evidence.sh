#!/usr/bin/env bash
set -euo pipefail

# Captura evidencias reais do cluster em arquivos .txt versionaveis.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
EVIDENCE_DIR="${EVIDENCE_DIR:-${REPO_ROOT}/evidence/logs}"
LAB_NAMESPACES="${LAB_NAMESPACES:-resilience-hpa resilience-scheduling}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Comando obrigatorio nao encontrado: $1"
    exit 1
  fi
}

capture_cmd() {
  local file_suffix="$1"
  shift
  local file_path="${EVIDENCE_DIR}/${TIMESTAMP}-${file_suffix}.txt"

  info "Capturando evidencias em: ${file_path#${REPO_ROOT}/}"
  {
    printf '# captured_at: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '# command: %s\n\n' "$*"
    if "$@"; then
      printf '\n# status: success\n'
    else
      status=$?
      printf '\n# status: failed (%s)\n' "${status}"
    fi
  } >"${file_path}" 2>&1
}

require_cmd kubectl

mkdir -p "${EVIDENCE_DIR}"

capture_cmd "01-current-context" kubectl config current-context
capture_cmd "02-nodes-wide" kubectl get nodes -o wide
capture_cmd "03-namespaces" kubectl get namespaces
capture_cmd "04-pods-all-wide" kubectl get pods -A -o wide
capture_cmd "05-deployments-all" kubectl get deployments -A
capture_cmd "06-services-all" kubectl get services -A
capture_cmd "07-hpa-all" kubectl get hpa -A
capture_cmd "08-node-labels" kubectl get nodes --show-labels
capture_cmd "09-node-taints" kubectl get nodes -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'
capture_cmd "10-metrics-api" kubectl get apiservice v1beta1.metrics.k8s.io
capture_cmd "11-top-nodes" kubectl top nodes
capture_cmd "12-top-pods-all" kubectl top pods -A

captured_lab_events=0
for namespace in ${LAB_NAMESPACES}; do
  if kubectl get namespace "${namespace}" >/dev/null 2>&1; then
    capture_cmd "13-events-${namespace}" kubectl get events -n "${namespace}" --sort-by=.metadata.creationTimestamp
    captured_lab_events=$((captured_lab_events + 1))
  else
    warn "Namespace ${namespace} nao encontrado."
  fi
done

if [[ "${captured_lab_events}" -eq 0 ]]; then
  warn "Nenhum namespace esperado foi encontrado. Capturando eventos globais."
  capture_cmd "13-events-all-namespaces" kubectl get events -A --sort-by=.metadata.creationTimestamp
fi

info "Captura concluida. Todos os arquivos .txt gerados sao outputs reais dos comandos executados."
