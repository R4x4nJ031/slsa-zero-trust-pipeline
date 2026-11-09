#!/usr/bin/env bash
set -euo pipefail
: "${PRODUCTION_KUBE_CONTEXT:?PRODUCTION_KUBE_CONTEXT must name the production cluster context}"

port="${PRODUCTION_SMOKE_TEST_PORT:-18081}"
kubectl --context "$PRODUCTION_KUBE_CONTEXT" -n production \
  port-forward service/cal-diy "${port}:8080" >/tmp/slsa-production-port-forward.log 2>&1 &
port_forward_pid=$!
trap 'kill "$port_forward_pid" 2>/dev/null || true' EXIT

curl --fail --silent --show-error --retry 20 --retry-connrefused --retry-delay 2 \
  "http://127.0.0.1:${port}/healthz"
