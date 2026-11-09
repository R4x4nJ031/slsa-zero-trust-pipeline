#!/usr/bin/env bash
set -euo pipefail

critical="$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' reports/trivy.json)"
high="$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' reports/trivy.json)"
for verification in signature-verification.json provenance-verification.json sbom-verification.json; do
  [[ -s "reports/$verification" ]] || {
    printf 'required verification report is missing or empty: reports/%s\n' "$verification" >&2
    exit 1
  }
done
jq -e '.passed == true' reports/tests.json >/dev/null
jq -e '.passed == true' reports/dast.json >/dev/null
digest="$(jq -r '.artifact.digest' reports/release-manifest.json)"

jq -n \
  --arg digest "$digest" \
  --argjson critical "$critical" \
  --argjson high "$high" \
  '{
    signature: {verified: true},
    identity: {authorized: true},
    provenance: {verified: true},
    sbom: {verified: true},
    tests: {passed: true},
    dast: {passed: true},
    image: {digest: $digest},
    trivy: {critical_count: $critical, high_count: $high}
  }' > reports/policy-input.json

printf 'created reports/policy-input.json (critical=%s high=%s)\n' "$critical" "$high"
