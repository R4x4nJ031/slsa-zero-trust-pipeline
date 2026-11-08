#!/usr/bin/env bash
set -euo pipefail

: "${OPA_INPUT:?OPA_INPUT must point to a verification result JSON file}"
opa eval --fail-defined --data security/opa/release.rego --input "$OPA_INPUT" 'data.release.allow == true'