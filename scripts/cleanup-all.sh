#!/usr/bin/env bash
set -euo pipefail

# Remove recursos aplicados pelo laboratorio sem apagar cluster por padrao.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFESTS_DIR="${MANIFESTS_DIR:-${REPO_ROOT}/manifests}"
CLUSTER_NAME="${CLUSTER_NAME:-resilience-ha-lab}"
LAB_NAMESPACES="${LAB_NAMESPACES:-resilience-hpa resilience-scheduling}"
DELETE_CLUSTER=false
DELETED_COUNT=0

if [[ "${1:-}" == "--delete-cluster" ]]; then
  DELETE_CLUSTER=true
fi

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Comando obrigatorio nao encontrado: $1"
    exit 1
  fi
}

delete_dir() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    return
  fi

  mapfile -t files < <(find "${dir}" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) | sort)
  if [[ ${#files[@]} -eq 0 ]]; then
    return
  fi

  info "Removendo recursos definidos em: ${dir}"
  for file in "${files[@]}"; do
    info "kubectl delete -f ${file#"${REPO_ROOT}"/} --ignore-not-found=true"
    kubectl delete -f "${file}" --ignore-not-found=true
    DELETED_COUNT=$((DELETED_COUNT + 1))
  done
}

require_cmd kubectl

if [[ ! -d "${MANIFESTS_DIR}" ]]; then
  warn "Pasta de manifests nao encontrada. Nada para remover via manifests."
fi

# Ordem reversa para evitar dependencias durante a remocao.
reverse_dirs=(
  "${MANIFESTS_DIR}/11-scheduler-default-behavior"
  "${MANIFESTS_DIR}/10-taints-tolerations"
  "${MANIFESTS_DIR}/09-pod-affinity"
  "${MANIFESTS_DIR}/08-pod-anti-affinity"
  "${MANIFESTS_DIR}/07-node-affinity-preferred"
  "${MANIFESTS_DIR}/06-node-affinity-required"
  "${MANIFESTS_DIR}/05-node-selector"
  "${MANIFESTS_DIR}/04-pod-distribution"
  "${MANIFESTS_DIR}/03-hpa-container-metrics"
  "${MANIFESTS_DIR}/02-hpa-scale-up-down"
  "${MANIFESTS_DIR}/01-hpa-basic"
)

for dir in "${reverse_dirs[@]}"; do
  delete_dir "${dir}"
done

# Fallback para estruturas fora do padrao modular.
if [[ -d "${MANIFESTS_DIR}" && "${DELETED_COUNT}" -eq 0 ]]; then
  warn "Estrutura modular nao encontrada. Removendo todos os YAMLs de manifests/."
  mapfile -t all_files < <(find "${MANIFESTS_DIR}" -type f \( -name '*.yaml' -o -name '*.yml' \) | sort)
  for file in "${all_files[@]}"; do
    info "kubectl delete -f ${file#"${REPO_ROOT}"/} --ignore-not-found=true"
    kubectl delete -f "${file}" --ignore-not-found=true
    DELETED_COUNT=$((DELETED_COUNT + 1))
  done
fi

for namespace in ${LAB_NAMESPACES}; do
  if kubectl get namespace "${namespace}" >/dev/null 2>&1; then
    info "Solicitando remocao do namespace ${namespace} (quando aplicavel)..."
    kubectl delete namespace "${namespace}" --ignore-not-found=true --wait=false
  fi
done

if [[ "${DELETE_CLUSTER}" == true ]]; then
  warn "Voce solicitou remocao completa do cluster '${CLUSTER_NAME}'."
  if command -v k3d >/dev/null 2>&1; then
    k3d cluster delete "${CLUSTER_NAME}" || warn "Nao foi possivel remover cluster '${CLUSTER_NAME}'."
  else
    warn "k3d nao encontrado. Remova o cluster manualmente."
  fi
else
  warn "Cluster NAO foi apagado automaticamente."
  info "Para remover manualmente: k3d cluster delete ${CLUSTER_NAME}"
  info "Ou execute este script com: ./scripts/cleanup-all.sh --delete-cluster"
fi

info "Limpeza finalizada."
