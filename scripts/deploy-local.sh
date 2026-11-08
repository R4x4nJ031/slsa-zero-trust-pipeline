#!/usr/bin/env bash
set -euo pipefail

image="${1:?usage: deploy-local.sh <ghcr-image@sha256:digest>}"
[[ "$image" =~ ^ghcr\.io/[^[:space:]]+@sha256:[0-9a-f]{64}$ ]] || {
  printf 'image must be a GHCR reference pinned to a sha256 digest\n' >&2
  exit 2
}
command -v envsubst >/dev/null || { printf 'envsubst is required (gettext package)\n' >&2; exit 2; }

export IMAGE_REF="$image"
rendered="$(mktemp)"
trap 'rm -f "$rendered"' EXIT
kubectl apply -f deploy/staging/namespace.yaml
kubectl apply -f deploy/staging/service.yaml
envsubst '${IMAGE_REF}' < deploy/staging/deployment.yaml > "$rendered"
kubectl apply -f "$rendered"
kubectl -n staging rollout status deployment/cal-diy --timeout=120s
