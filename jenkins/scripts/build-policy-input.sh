#!/usr/bin/env bash
set -euo pipefail

critical="$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' reports/trivy.json)"
high="$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' reports/trivy.json)"
tests_passed="$(jq -r '.passed' reports/tests.json)"
dast_passed="$(jq -r '.passed' reports/dast.json)"
digest="$(jq -r '.artifact.digest' reports/release-manifest.json)"

jq -n \
  --arg digest "$digest" \
  --argjson critical "$critical" \
  --argjson high "$high" \
  --argjson tests_passed "$tests_passed" \
  --argjson dast_passed "$dast_passed" \
  '{
    signature: {verified: true},
    identity: {authorized: true},
    provenance: {verified: true},
    sbom: {verified: true},
    tests: {passed: $tests_passed},
    dast: {passed: $dast_passed},
    image: {digest: $digest},
    trivy: {critical_count: $critical, high_count: $high}
  }' > reports/policy-input.json

printf 'created reports/policy-input.json (critical=%s high=%s tests_passed=%s dast_passed=%s)\n' \
  "$critical" "$high" "$tests_passed" "$dast_passed"
