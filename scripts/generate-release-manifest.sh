#!/usr/bin/env bash
set -euo pipefail

: "${IMAGE_DIGEST:?IMAGE_DIGEST is required}"
: "${GITHUB_SHA:?GITHUB_SHA is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${GITHUB_REF:?GITHUB_REF is required}"
: "${GITHUB_RUN_ID:?GITHUB_RUN_ID is required}"
: "${GITHUB_WORKFLOW_FILE:?GITHUB_WORKFLOW_FILE is required}"
: "${IMAGE_REPOSITORY:?IMAGE_REPOSITORY is required}"

mkdir -p reports
jq -n \
  --arg commit "$GITHUB_SHA" \
  --arg repository "$GITHUB_REPOSITORY" \
  --arg ref "$GITHUB_REF" \
  --arg run_id "$GITHUB_RUN_ID" \
  --arg workflow "$GITHUB_WORKFLOW_FILE" \
  --arg image "$IMAGE_REPOSITORY" \
  --arg digest "$IMAGE_DIGEST" \
  --arg release_id "${GITHUB_RUN_ID}-${GITHUB_SHA:0:12}" \
  '{
    schema_version: "1.0",
    release_id: $release_id,
    source: { repository: $repository, commit: $commit, ref: $ref },
    builder: { platform: "github-actions", workflow: $workflow, run_id: $run_id },
    artifact: { type: "container", repository: $image, digest: $digest },
    evidence: { signature: "cosign", sbom: "cyclonedx", provenance: "slsa" },
    status: "candidate"
  }' > reports/release-manifest.json

printf 'wrote reports/release-manifest.json\n'