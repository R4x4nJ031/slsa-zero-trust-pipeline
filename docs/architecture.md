# Architecture

The pipeline has four trust boundaries:

1. GitHub Actions scans the source revision, runs tests, builds the image, and produces the digest, SBOM, scan reports, signature, provenance, and release manifest.
2. GHCR stores the immutable image and its attached evidence.
3. Jenkins downloads the manifest and scan evidence from the referenced GitHub Actions run, then independently verifies the Cosign signature, GitHub provenance, and SBOM attestation before deploying the digest.
4. Kubernetes and Kyverno enforce the final admission decision, even if Jenkins is bypassed.

The image digest is the artifact identity. Tags are only discovery aliases and must never be used for deployment.

The GitHub provenance is generated as a GitHub artifact attestation and pushed to GHCR as an OCI artifact. Jenkins verifies it with `gh attestation verify`; Kyverno verifies the registry-attached Sigstore bundle. Cosign separately signs the image and SBOM attestation.

The example organization and workflow identity in the Kyverno policy must be replaced before installation.
