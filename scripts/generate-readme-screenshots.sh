#!/usr/bin/env bash
set -euo pipefail

# Gera screenshots PNG reais para o README a partir da saida dos comandos do cluster.
CONTEXT="${CONTEXT:-k3d-resilience-ha-lab}"
RENDER_IMAGE="${RENDER_IMAGE:-python:3.12-slim}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCREENSHOT_DIR="${SCREENSHOT_DIR:-${REPO_ROOT}/evidence/screenshots}"
BUILD_DIR="${SCREENSHOT_DIR}/.build"
FONT_DIR="${FONT_DIR:-/usr/share/fonts/truetype/dejavu}"
FONT_PATH_CONTAINER="/fonts/DejaVuSansMono.ttf"
PROMPT_PREFIX=$'\033[1;32mluizandre@DESKTOP-6NVO7GR\033[0m:\033[1;34m~/Repositorios/kubernetes-resilience-ha-lab\033[0m$ '

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Comando obrigatorio nao encontrado: $1"
    exit 1
  fi
}

render_capture() {
  local input_rel="$1"
  local output_rel="$2"

  docker run --rm \
    -v "${REPO_ROOT}:/work" \
    -v "${FONT_DIR}:/fonts:ro" \
    -w /work \
    "${RENDER_IMAGE}" \
    sh -lc 'python -m pip install --quiet pillow >/tmp/pillow.log && python scripts/render-terminal-screenshot.py --input "$1" --output "$2" --font "$3"' \
    _ "/work/${input_rel}" "/work/${output_rel}" "${FONT_PATH_CONTAINER}" >/dev/null
}

capture_command() {
  local name="$1"
  local display_command="$2"
  local exec_command="$3"
  local text_rel="evidence/screenshots/.build/${name}.txt"
  local image_rel="evidence/screenshots/${name}.png"
  local text_abs="${REPO_ROOT}/${text_rel}"

  info "Gerando screenshot: ${name}.png"
  {
    printf '%b%s\n' "${PROMPT_PREFIX}" "${display_command}"
    bash -lc "${exec_command}"
  } > "${text_abs}" 2>&1

  render_capture "${text_rel}" "${image_rel}"
}

require_cmd kubectl
require_cmd docker

mkdir -p "${BUILD_DIR}"

kubectl config use-context "${CONTEXT}" >/dev/null

# Preserva o screenshot manual do GitHub Actions antes da limpeza.
gh_actions_backup=""
if [[ -f "${SCREENSHOT_DIR}/11-github-actions-yaml-validation.png" ]]; then
  gh_actions_backup="${BUILD_DIR}/11-github-actions-yaml-validation.png"
  cp "${SCREENSHOT_DIR}/11-github-actions-yaml-validation.png" "${gh_actions_backup}"
elif [[ -f "${SCREENSHOT_DIR}/10-github-actions-yaml-validation.png" ]]; then
  gh_actions_backup="${BUILD_DIR}/10-github-actions-yaml-validation.png"
  cp "${SCREENSHOT_DIR}/10-github-actions-yaml-validation.png" "${gh_actions_backup}"
fi

# Remove screenshots herdados de outro laboratorio e qualquer render anterior.
rm -f "${SCREENSHOT_DIR}"/*.png

capture_command \
  "01-cluster-nodes" \
  "kubectl get nodes -o wide" \
  "kubectl --context ${CONTEXT} get nodes -o wide"

capture_command \
  "02-metrics-top-nodes" \
  "kubectl top nodes" \
  "kubectl --context ${CONTEXT} top nodes"

capture_command \
  "03-hpa-basic-overview" \
  "kubectl get hpa -n resilience-hpa" \
  "kubectl --context ${CONTEXT} get hpa -n resilience-hpa"

capture_command \
  "04-hpa-scale-up" \
  "kubectl get hpa,pods -n resilience-hpa" \
  "kubectl --context ${CONTEXT} get hpa,pods -n resilience-hpa"

capture_command \
  "05-hpa-container-resource" \
  "kubectl describe hpa hpa-container-app -n resilience-hpa | sed -n '1,120p'" \
  "kubectl --context ${CONTEXT} describe hpa hpa-container-app -n resilience-hpa | sed -n '1,120p'"

capture_command \
  "06-pod-distribution-wide" \
  "kubectl get pods -n resilience-scheduling -l module=pod-distribution -o wide" \
  "kubectl --context ${CONTEXT} get pods -n resilience-scheduling -l module=pod-distribution -o wide"

capture_command \
  "07-node-labels" \
  "kubectl get nodes -L workload,disk,zone,dedicated" \
  "kubectl --context ${CONTEXT} get nodes -L workload,disk,zone,dedicated"

capture_command \
  "08-node-selector-and-node-affinity" \
  "kubectl get pods -n resilience-scheduling -l module=<selector|affinity> -o wide" \
  "kubectl --context ${CONTEXT} get pods -n resilience-scheduling -l 'module in (node-selector,node-affinity-required,node-affinity-preferred)' -o wide"

capture_command \
  "09-pod-affinity-and-anti-affinity" \
  "kubectl get pods -n resilience-scheduling -l module=<pod-affinity|anti-affinity> -o wide" \
  "kubectl --context ${CONTEXT} get pods -n resilience-scheduling -l 'module in (pod-affinity,pod-anti-affinity)' -o wide"

capture_command \
  "10-taints-and-tolerations" \
  "kubectl get pods -n resilience-scheduling -l module=taints-tolerations -o wide && kubectl describe pod pod-without-toleration -n resilience-scheduling" \
  "kubectl --context ${CONTEXT} get pods -n resilience-scheduling -l module=taints-tolerations -o wide; printf '\n'; kubectl --context ${CONTEXT} describe pod pod-without-toleration -n resilience-scheduling | sed -n '/Events:/,\$p'"

if [[ -n "${gh_actions_backup}" ]]; then
  cp "${gh_actions_backup}" "${SCREENSHOT_DIR}/11-github-actions-yaml-validation.png"
  info "Screenshot do GitHub Actions preservado como 11-github-actions-yaml-validation.png."
else
  warn "Screenshot do GitHub Actions nao encontrado. Gere manualmente e salve como 11-github-actions-yaml-validation.png."
fi

info "Screenshots do README atualizados em ${SCREENSHOT_DIR}."
