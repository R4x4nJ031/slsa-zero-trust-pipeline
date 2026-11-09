#!/usr/bin/env bash
set -euo pipefail
: "${STAGING_KUBE_CONTEXT:?STAGING_KUBE_CONTEXT must name the staging cluster context}"

image="$(jq -r '.artifact.repository + "@" + .artifact.digest' reports/release-manifest.json)"
export IMAGE_REF="$image"
rendered="$(mktemp)"
trap 'rm -f "$rendered"' EXIT
kubectl --context "$STAGING_KUBE_CONTEXT" apply -f deploy/staging/namespace.yaml
kubectl --context "$STAGING_KUBE_CONTEXT" apply -f deploy/staging/service.yaml
envsubst '${IMAGE_REF}' < deploy/staging/deployment.yaml > "$rendered"
kubectl --context "$STAGING_KUBE_CONTEXT" apply -f "$rendered"
kubectl --context "$STAGING_KUBE_CONTEXT" -n staging rollout status deployment/cal-diy --timeout=120s
