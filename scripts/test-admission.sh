#!/usr/bin/env bash
set -euo pipefail

image="${1:?usage: test-admission.sh <authorized-image@sha256:digest>}"
[[ "$image" =~ ^ghcr\.io/[^[:space:]]+@sha256:[0-9a-f]{64}$ ]] || {
  printf 'provide a GHCR image pinned to a sha256 digest\n' >&2
  exit 2
}
command -v kubectl >/dev/null || { printf 'kubectl is required\n' >&2; exit 2; }

temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

make_pod() {
  local path="$1" image_ref="$2" privileged="${3:-false}"
  cat > "$path" <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: admission-check
  namespace: staging
  labels:
    app: admission-check
spec:
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      image: ${image_ref}
      securityContext:
        privileged: ${privileged}
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
EOF
}

expect_admitted() {
  local manifest="$1" description="$2"
  if kubectl create --dry-run=server -f "$manifest" >/dev/null 2>&1; then
    printf 'PASS admitted: %s\n' "$description"
  else
    printf 'FAIL expected admission: %s\n' "$description" >&2
    kubectl create --dry-run=server -f "$manifest" >&2 || true
    exit 1
  fi
}

expect_denied() {
  local manifest="$1" description="$2"
  if kubectl create --dry-run=server -f "$manifest" >/dev/null 2>&1; then
    printf 'FAIL expected denial: %s\n' "$description" >&2
    exit 1
  else
    printf 'PASS denied: %s\n' "$description"
  fi
}

make_pod "$temporary_dir/valid.yaml" "$image"
expect_admitted "$temporary_dir/valid.yaml" 'authorized signed digest with secure pod settings'

repository="${image%@sha256:*}"
make_pod "$temporary_dir/tagged.yaml" "${repository}:latest"
expect_denied "$temporary_dir/tagged.yaml" 'mutable image tag'

make_pod "$temporary_dir/privileged.yaml" "$image" true
expect_denied "$temporary_dir/privileged.yaml" 'privileged container'

make_pod "$temporary_dir/unapproved.yaml" 'docker.io/library/busybox@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
expect_denied "$temporary_dir/unapproved.yaml" 'unapproved registry'
