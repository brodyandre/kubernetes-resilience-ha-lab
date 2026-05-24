#!/usr/bin/env bash
set -euo pipefail

# Aplica manifests Kubernetes em ordem modular e de forma idempotente.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFESTS_DIR="${MANIFESTS_DIR:-${REPO_ROOT}/manifests}"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Comando obrigatorio nao encontrado: $1"
    exit 1
  fi
}

apply_dir() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    warn "Diretorio nao encontrado, ignorando: ${dir}"
    return
  fi

  mapfile -t files < <(find "${dir}" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) | sort)
  if [[ ${#files[@]} -eq 0 ]]; then
    warn "Nenhum manifest YAML encontrado em: ${dir}"
    return
  fi

  info "Aplicando manifests em: ${dir}"
  local namespace_files=()
  local regular_files=()
  for file in "${files[@]}"; do
    if [[ "$(basename "${file}")" == "namespace.yaml" || "$(basename "${file}")" == "namespace.yml" ]]; then
      namespace_files+=("${file}")
    else
      regular_files+=("${file}")
    fi
  done

  for file in "${namespace_files[@]}"; do
    info "kubectl apply -f ${file#"${REPO_ROOT}"/}"
    kubectl apply -f "${file}"
    APPLIED_COUNT=$((APPLIED_COUNT + 1))
  done

  for file in "${regular_files[@]}"; do
    info "kubectl apply -f ${file#"${REPO_ROOT}"/}"
    kubectl apply -f "${file}"
    APPLIED_COUNT=$((APPLIED_COUNT + 1))
  done
}

require_cmd kubectl

if [[ ! -d "${MANIFESTS_DIR}" ]]; then
  error "Pasta de manifests nao encontrada: ${MANIFESTS_DIR}"
  exit 1
fi

info "Validando conectividade com cluster..."
kubectl cluster-info >/dev/null

APPLIED_COUNT=0

# Ordem recomendada para aplicacao segura e previsivel.
ordered_dirs=(
  "${MANIFESTS_DIR}/01-hpa-basic"
  "${MANIFESTS_DIR}/02-hpa-scale-up-down"
  "${MANIFESTS_DIR}/03-hpa-container-metrics"
  "${MANIFESTS_DIR}/04-pod-distribution"
  "${MANIFESTS_DIR}/05-node-selector"
  "${MANIFESTS_DIR}/06-node-affinity-required"
  "${MANIFESTS_DIR}/07-node-affinity-preferred"
  "${MANIFESTS_DIR}/08-pod-anti-affinity"
  "${MANIFESTS_DIR}/09-pod-affinity"
  "${MANIFESTS_DIR}/10-taints-tolerations"
  "${MANIFESTS_DIR}/11-scheduler-default-behavior"
)

for dir in "${ordered_dirs[@]}"; do
  apply_dir "${dir}"
done

# Fallback: se os modulos acima ainda nao existirem, aplica qualquer YAML de manifests/.
if [[ "${APPLIED_COUNT}" -eq 0 ]]; then
  warn "Nenhum arquivo aplicado na estrutura modular padrao. Aplicando YAMLs encontrados em manifests/."
  mapfile -t all_files < <(find "${MANIFESTS_DIR}" -type f \( -name '*.yaml' -o -name '*.yml' \) | sort)
  for file in "${all_files[@]}"; do
    info "kubectl apply -f ${file#"${REPO_ROOT}"/}"
    kubectl apply -f "${file}"
    APPLIED_COUNT=$((APPLIED_COUNT + 1))
  done
fi

if [[ "${APPLIED_COUNT}" -eq 0 ]]; then
  warn "Nenhum manifest YAML encontrado para aplicar."
else
  info "Aplicacao concluida. Total de arquivos aplicados: ${APPLIED_COUNT}"
fi
