#!/usr/bin/env bash
set -euo pipefail

image="$(jq -r '.artifact.repository + "@" + .artifact.digest' reports/release-manifest.json)"
export IMAGE_REF="$image"
rendered="$(mktemp)"
trap 'rm -f "$rendered"' EXIT
kubectl apply -f deploy/production/namespace.yaml
envsubst '${IMAGE_REF}' < deploy/production/deployment.yaml > "$rendered"
kubectl apply -f "$rendered"
kubectl -n production rollout status deployment/cal-diy --timeout=120s
