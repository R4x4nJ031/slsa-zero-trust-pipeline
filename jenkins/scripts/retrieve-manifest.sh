#!/usr/bin/env bash
set -euo pipefail

repository="${1:?GitHub repository (OWNER/REPO) is required}"
run_id="${2:?GitHub Actions run ID is required}"
commit="${3:?source commit SHA is required}"
[[ "$repository" =~ ^[^/[:space:]]+/[^/[:space:]]+$ ]] || { printf 'invalid repository: %s\n' "$repository" >&2; exit 2; }
[[ "$run_id" =~ ^[0-9]+$ ]] || { printf 'invalid run ID: %s\n' "$run_id" >&2; exit 2; }
[[ "$commit" =~ ^[0-9a-f]{40}$ ]] || { printf 'invalid source commit: %s\n' "$commit" >&2; exit 2; }
: "${GH_TOKEN:?GH_TOKEN is required to download the workflow artifact}"

mkdir -p reports
download_dir="$(mktemp -d)"
trap 'rm -rf "$download_dir"' EXIT
gh run download "$run_id" --repo "$repository" \
  --name "release-evidence-${commit}" --dir "$download_dir"
cp "$download_dir/release-manifest.json" reports/release-manifest.json
cp "$download_dir/trivy.json" reports/trivy.json
cp "$download_dir/tests.json" reports/tests.json
cp "$download_dir/sbom.cdx.json" reports/sbom.cdx.json
