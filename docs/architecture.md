# Architecture

The pipeline has four trust boundaries:

1. GitHub Actions builds the image from a repository revision and produces the digest, SBOM, signature, provenance, and release manifest.
2. GHCR stores the immutable image and its attached evidence.
3. Jenkins retrieves the manifest as a locator, then independently verifies the image and attestations before deploying the digest.
4. Kubernetes and Kyverno enforce the final admission decision, even if Jenkins is bypassed.

The image digest is the artifact identity. Tags are only discovery aliases and must never be used for deployment.

The example organization and workflow identity in the Kyverno policy must be replaced before installation.