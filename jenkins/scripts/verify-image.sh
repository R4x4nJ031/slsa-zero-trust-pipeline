#!/usr/bin/env bash
set -euo pipefail

image="$(jq -r '.artifact.repository + "@" + .artifact.digest' reports/release-manifest.json)"
: "${COSIGN_CERT_IDENTITY:?COSIGN_CERT_IDENTITY is required}"
: "${COSIGN_CERT_OIDC_ISSUER:?COSIGN_CERT_OIDC_ISSUER is required}"

cosign verify "$image" \
  --certificate-identity "$COSIGN_CERT_IDENTITY" \
  --certificate-oidc-issuer "$COSIGN_CERT_OIDC_ISSUER"