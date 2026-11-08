#!/usr/bin/env bash
set -euo pipefail

manifest="${1:-}"
schema="$(dirname "$0")/../security/schemas/release-manifest.schema.json"

if [[ -z "$manifest" ]]; then
  printf 'usage: %s <manifest.json>\n' "$0" >&2
  exit 2
fi

if [[ ! -f "$manifest" ]]; then
  printf 'manifest not found: %s\n' "$manifest" >&2
  exit 2
fi

if command -v ajv >/dev/null 2>&1; then
  validator=(ajv)
elif command -v npx >/dev/null 2>&1; then
  validator=(npx --yes ajv-cli)
else
  printf 'missing required command: ajv or npx\n' >&2
  printf 'install Node.js, then rerun this test\n' >&2
  exit 2
fi

"${validator[@]}" validate -s "$schema" -d "$manifest" --spec=draft2020