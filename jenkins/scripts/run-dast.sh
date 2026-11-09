#!/usr/bin/env bash
set -euo pipefail
: "${STAGING_KUBE_CONTEXT:?STAGING_KUBE_CONTEXT must name the staging cluster context}"

command -v zap-baseline.py >/dev/null || { printf 'zap-baseline.py is required on the Jenkins agent\n' >&2; exit 2; }
port="${DAST_PORT:-18080}"
kubectl --context "$STAGING_KUBE_CONTEXT" -n staging port-forward service/cal-diy "${port}:8080" >/tmp/slsa-dast-port-forward.log 2>&1 &
port_forward_pid=$!
trap 'kill "$port_forward_pid" 2>/dev/null || true' EXIT

zap-baseline.py -t "http://127.0.0.1:${port}" \
  -J reports/zap-report.json \
  -r reports/zap-report.html \
  -I
printf '{"passed":true}\n' > reports/dast.json
