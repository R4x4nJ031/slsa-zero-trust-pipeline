#!/usr/bin/env bash
set -euo pipefail

: "${OPA_INPUT:?OPA_INPUT must point to a verification result JSON file}"
decision="$(opa eval --format raw --data security/opa/release.rego --input "$OPA_INPUT" 'data.release.allow')"
if [[ "$decision" != "true" ]]; then
  printf 'release policy denied candidate\n' >&2
  opa eval --format pretty --data security/opa/release.rego --input "$OPA_INPUT" 'data.release.deny' >&2
  exit 1
fi

printf 'release policy allowed candidate\n'
