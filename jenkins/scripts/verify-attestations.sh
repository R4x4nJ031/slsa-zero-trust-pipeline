#!/usr/bin/env bash
set -euo pipefail

image="$(jq -r '.artifact.repository + "@" + .artifact.digest' reports/release-manifest.json)"
repository="$(jq -r '.source.repository' reports/release-manifest.json)"
workflow="$(jq -r '.builder.workflow' reports/release-manifest.json)"
ref="$(jq -r '.source.ref' reports/release-manifest.json)"
identity="https://github.com/${repository}/${workflow}@${ref}"
issuer="https://token.actions.githubusercontent.com"

gh attestation verify "oci://${image}" --repo "$repository" \
  --signer-workflow "${repository}/${workflow}" --source-ref "$ref" --format json \
  > reports/provenance-verification.json

cosign verify-attestation "$image" --type cyclonedx \
  --certificate-identity "$identity" \
  --certificate-oidc-issuer "$issuer" > reports/sbom-verification.json
