#!/usr/bin/env bash
set -euo pipefail

# Instala e ajusta o Metrics Server para suportar HPA em ambiente local.
METRICS_SERVER_URL="${METRICS_SERVER_URL:-https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml}"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Comando obrigatorio nao encontrado: $1"
    exit 1
  fi
}

add_arg_if_missing() {
  local arg="$1"
  if kubectl -n kube-system get deployment metrics-server -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- "${arg}"; then
    info "Argumento ja configurado no metrics-server: ${arg}"
  else
    info "Adicionando argumento no metrics-server: ${arg}"
    kubectl -n kube-system patch deployment metrics-server \
      --type='json' \
      -p="[ {\"op\":\"add\",\"path\":\"/spec/template/spec/containers/0/args/-\",\"value\":\"${arg}\"} ]"
  fi
}

require_cmd kubectl

info "Instalando Metrics Server..."
kubectl apply -f "${METRICS_SERVER_URL}"

# HPA depende da API de metricas (metrics.k8s.io). Sem Metrics Server, HPA nao consegue
# calcular escala com base em consumo de CPU/memoria em ambientes locais.
info "Aplicando ajustes para ambiente local (k3d/kind)..."
add_arg_if_missing "--kubelet-insecure-tls"
add_arg_if_missing "--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP"

info "Aguardando rollout do metrics-server..."
kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s

info "Status da API de metricas:"
if kubectl get apiservice v1beta1.metrics.k8s.io >/dev/null 2>&1; then
  kubectl get apiservice v1beta1.metrics.k8s.io
else
  warn "APIService v1beta1.metrics.k8s.io ainda nao encontrada."
fi

info "Tentando validar metricas com kubectl top..."
if kubectl top nodes >/dev/null 2>&1; then
  kubectl top nodes
else
  warn "kubectl top nodes ainda indisponivel. Aguarde alguns instantes e tente novamente."
fi

if kubectl top pods -A >/dev/null 2>&1; then
  kubectl top pods -A
else
  warn "kubectl top pods ainda indisponivel. Aguarde alguns instantes e tente novamente."
fi

info "Instalacao do Metrics Server finalizada."
