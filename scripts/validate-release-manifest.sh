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

python3 "$(dirname "$0")/validate_release_manifest.py" "$schema" "$manifest"
