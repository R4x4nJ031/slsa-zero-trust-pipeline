#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
validator="$root/scripts/validate-release-manifest.sh"
valid="$root/security/schemas/release-manifest.valid.json"
invalid="$root/security/schemas/release-manifest.invalid.json"

"$validator" "$valid" >/dev/null

if "$validator" "$invalid" >/dev/null 2>&1; then
  printf 'expected invalid manifest to fail validation\n' >&2
  exit 1
fi

printf 'release manifest validation tests passed\n'