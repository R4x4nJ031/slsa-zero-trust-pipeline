#!/usr/bin/env bash
set -euo pipefail

if ! command -v opa >/dev/null 2>&1; then
  printf 'missing required command: opa\n' >&2
  printf 'install OPA before running policy tests: https://openpolicyagent.org/docs/latest/#running-opa\n' >&2
  exit 2
fi

opa test security/opa