# SLSA Zero-Trust Pipeline

This repository builds a small, testable supply-chain security lab around a container artifact.

The first milestone defines the release-manifest contract shared by GitHub Actions and Jenkins. The manifest identifies the source commit, trusted builder, immutable image digest, and required evidence. It is metadata, not proof: Jenkins must independently verify the referenced signature and attestations later.

## First milestone

The validator uses a local `ajv` binary when available, or downloads `ajv-cli` through `npx`:

```sh
npm install --global ajv-cli # optional
```

Run the focused contract test:

```sh
./test/validate-release-manifest.sh
```

## Repository map

- `src/` and `Dockerfile`: minimal reference service and non-root container image.
- `.github/workflows/`: contract validation and trusted image build workflow.
- `security/opa/`: release decision policy and tests.
- `security/kyverno/`: runtime admission policies.
- `jenkins/`: independent verification and deployment stages.
- `scripts/`: manifest generation and validation helpers.
- `docs/`: architecture, threats, and attack cases.

## Local checks

```sh
make test
make policy # requires opa
make build
```

For a local Kubernetes lab, create Kind and install Kyverno, then apply the staging manifests and policies:

```sh
kind create cluster --config deploy/kind/kind-config.yaml
kubectl apply -f security/kyverno/
kubectl apply -f deploy/staging/
```

The GitHub workflow requires GHCR, Sigstore, and GitHub Actions permissions. Before using it, replace the example organization in `security/kyverno/verify-image.yaml` and `deploy/staging/deployment.yaml` with the real organization. Configure Jenkins with the expected Cosign identity and OIDC issuer. Jenkins must verify the actual artifact; the manifest is only a locator.