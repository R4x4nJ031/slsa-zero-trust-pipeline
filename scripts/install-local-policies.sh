#!/usr/bin/env bash
set -euo pipefail

repository="${1:?usage: install-local-policies.sh <OWNER/REPO>}"
[[ "$repository" =~ ^[^/[:space:]]+/[^/[:space:]]+$ ]] || { printf 'repository must be OWNER/REPO\n' >&2; exit 2; }
command -v envsubst >/dev/null || { printf 'envsubst is required (gettext package)\n' >&2; exit 2; }
command -v kubectl >/dev/null || { printf 'kubectl is required\n' >&2; exit 2; }

export SOURCE_REPOSITORY="$repository"
export IMAGE_REPOSITORY="ghcr.io/${repository,,}"
export SOURCE_REF="refs/heads/main"
export WORKFLOW_PATH=".github/workflows/build-image.yml"
rendered="$(mktemp -d)"
trap 'rm -rf "$rendered"' EXIT

for policy in security/kyverno/*.yaml; do
  name="$(basename "$policy")"
  envsubst '${SOURCE_REPOSITORY} ${IMAGE_REPOSITORY} ${SOURCE_REF} ${WORKFLOW_PATH}' \
    < "$policy" > "$rendered/$name"
done

kubectl apply -f "$rendered"
