# Threat model

The primary attacker is an untrusted pull request author or a compromised integration credential. They may submit workflow changes, forge release metadata, replace a mutable tag, publish an unsigned image, or submit a direct Kubernetes workload.

The controls are deliberately layered:

- Pull requests do not receive release credentials.
- The release manifest is schema-validated but never trusted as proof.
- Jenkins verifies the digest, Cosign identity, provenance, and SBOM independently.
- Jenkins deploys only the digest it verified and never rebuilds.
- Kyverno rejects mutable, unapproved, unsigned, or privileged workloads.
- Missing evidence or a failed scanner is inconclusive and therefore blocks release.