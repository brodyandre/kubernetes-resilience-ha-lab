#!/usr/bin/env bash
set -euo pipefail

# Cria (ou reutiliza) o cluster local k3d para o laboratorio.
CLUSTER_NAME="${CLUSTER_NAME:-resilience-ha-lab}"
SERVERS="${SERVERS:-1}"
AGENTS="${AGENTS:-3}"
CONTEXT_NAME="k3d-${CLUSTER_NAME}"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Comando obrigatorio nao encontrado: $1"
    exit 1
  fi
}

require_cmd k3d
require_cmd kubectl

info "Preparando cluster k3d '${CLUSTER_NAME}' (server=${SERVERS}, agents=${AGENTS})..."

if k3d cluster list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "${CLUSTER_NAME}"; then
  warn "Cluster '${CLUSTER_NAME}' ja existe. Reutilizando cluster atual."
else
  k3d cluster create "${CLUSTER_NAME}" --servers "${SERVERS}" --agents "${AGENTS}"
fi

info "Configurando contexto kubectl: ${CONTEXT_NAME}"
kubectl config use-context "${CONTEXT_NAME}" >/dev/null

info "Contexto atual:"
kubectl config current-context

info "Validando nodes do cluster (kubectl get nodes -o wide):"
kubectl get nodes -o wide

info "Setup finalizado com sucesso."
