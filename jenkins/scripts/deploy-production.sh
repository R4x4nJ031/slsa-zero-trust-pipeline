#!/usr/bin/env bash
set -euo pipefail

image="$(jq -r '.artifact.repository + "@" + .artifact.digest' reports/release-manifest.json)"
kubectl -n production set image deployment/cal-diy cal-diy="$image"
kubectl -n production rollout status deployment/cal-diy --timeout=120s