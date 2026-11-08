#!/usr/bin/env bash
set -euo pipefail

image="$(jq -r '.artifact.repository + "@" + .artifact.digest' reports/release-manifest.json)"
kubectl -n staging set image deployment/cal-diy cal-diy="$image"
kubectl -n staging rollout status deployment/cal-diy --timeout=120s