#!/usr/bin/env bash
set -euo pipefail

url="${1:?manifest URL is required}"
mkdir -p reports
curl --fail --location --proto '=https' --tlsv1.2 "$url" -o reports/release-manifest.json
jq -e '.artifact.repository | startswith("ghcr.io/")' reports/release-manifest.json >/dev/null
jq -e '.artifact.digest | test("^sha256:[0-9a-f]{64}$")' reports/release-manifest.json >/dev/null