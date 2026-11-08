#!/usr/bin/env bash
set -euo pipefail

image="$(jq -r '.artifact.repository + "@" + .artifact.digest' reports/release-manifest.json)"
export IMAGE_REF="$image"
rendered="$(mktemp)"
trap 'rm -f "$rendered"' EXIT
kubectl apply -f deploy/staging/namespace.yaml
kubectl apply -f deploy/staging/service.yaml
envsubst '${IMAGE_REF}' < deploy/staging/deployment.yaml > "$rendered"
kubectl apply -f "$rendered"
kubectl -n staging rollout status deployment/cal-diy --timeout=120s
