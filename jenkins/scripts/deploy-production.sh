#!/usr/bin/env bash
set -euo pipefail
: "${PRODUCTION_KUBE_CONTEXT:?PRODUCTION_KUBE_CONTEXT must name the production cluster context}"

image="$(jq -r '.artifact.repository + "@" + .artifact.digest' reports/release-manifest.json)"
export IMAGE_REF="$image"
rendered="$(mktemp)"
trap 'rm -f "$rendered"' EXIT
kubectl --context "$PRODUCTION_KUBE_CONTEXT" apply -f deploy/production/namespace.yaml
kubectl --context "$PRODUCTION_KUBE_CONTEXT" apply -f deploy/production/service.yaml
envsubst '${IMAGE_REF}' < deploy/production/deployment.yaml > "$rendered"
kubectl --context "$PRODUCTION_KUBE_CONTEXT" apply -f "$rendered"
kubectl --context "$PRODUCTION_KUBE_CONTEXT" -n production rollout status deployment/cal-diy --timeout=120s
