# SLSA Zero-Trust Pipeline Lab

This repository is a hands-on supply-chain security lab. It builds a small Node.js reference service into a container, creates an SBOM and vulnerability report, signs the image, attaches GitHub build provenance, asks Jenkins to verify the exact digest independently, and uses Kyverno to enforce policy at Kubernetes admission.

The reference service is intentionally small so the pipeline is the focus. It is not the Cal.diy application itself; replace `src/` and its Docker build context when you are ready to protect that application.

## Release path

1. Pull requests and pushes to `main` scan repository history with Gitleaks and source code with Semgrep. A push to `main` also runs Node tests and scans configuration with Trivy.
2. GitHub Actions creates a CycloneDX SBOM, Trivy report, and release manifest. The build fails on HIGH or CRITICAL findings.
3. A separate trusted job signs the image with Cosign, attaches the SBOM attestation, and attaches SLSA build provenance to GHCR.
4. If Jenkins triggering is configured, Jenkins downloads evidence from that exact workflow run, validates the manifest, independently verifies the signer and attestations, deploys the digest to staging, and runs a health check.
5. OPA evaluates the verified evidence. A human approval gates production promotion of the same digest.
6. Kyverno independently checks signatures, provenance, image digests, registry, and pod security at admission.

The release manifest is a locator and metadata contract. It is not proof by itself.

## Run local checks

Requirements: Bash, Python 3, Node.js 22 or newer, Docker, OPA, `jq`, and (for the cluster lab) Kind, `kubectl`, Helm, and `envsubst` from `gettext`.

```sh
make test
make policy
make build
make scan
```

`make test` runs manifest validation, the service tests, and shell syntax checks. `make build` builds the local image. `make scan` uses Trivy in Docker to scan that image and fails on HIGH or CRITICAL findings with a fix available; `make scan-config` scans Docker and Kubernetes configuration. The manifest validator uses only Python's standard library and does not download dependencies. The reference service has no third-party Node dependencies; Syft records the final image contents and Trivy scans the published image.

## Configure GitHub Actions

The workflows use the built-in `GITHUB_TOKEN`. In repository settings, allow Actions to publish packages to GHCR. Build and signing jobs run only for pushes to `main`; pull requests run the read-only source security and release-contract checks. The package should be public for the unauthenticated Kind lab. Protect `main` with required checks for `source-security` and `validate-release-contract`, and require review for changes to workflow and security policy files.

For GitHub organizations that require a Gitleaks license, add `GITLEAKS_LICENSE` as an Actions secret. Personal accounts and public repositories can leave it unset.

To have a successful signed candidate trigger Jenkins, add these repository Actions secrets:

| Secret | Value |
| --- | --- |
| `JENKINS_JOB_URL` | Full HTTPS URL of the Jenkins pipeline job, without `/buildWithParameters` |
| `JENKINS_USER` | Jenkins user that owns the API token |
| `JENKINS_API_TOKEN` | Jenkins API token for that user |

If all three are absent, the build still publishes evidence and simply skips the Jenkins notification.

When Jenkins triggering is enabled, also add these Actions repository variables (Settings → Secrets and variables → Actions → Variables):

| Variable | Value |
| --- | --- |
| `STAGING_KUBE_CONTEXT` | The kubeconfig context name Jenkins should use for staging |
| `PRODUCTION_KUBE_CONTEXT` | The kubeconfig context name Jenkins should use for production |

## Configure Jenkins

Create a Pipeline job named `slsa-zero-trust-release` from this repository's `jenkins/Jenkinsfile`. Configure an isolated agent with Bash, Python 3, Node.js, `gh`, Cosign, Docker, `kubectl`, OPA, `jq`, `envsubst`, `curl`, and OWASP ZAP's `zap-baseline.py`. The agent needs access to the staging and production cluster contexts.

Add these Jenkins credentials:

| Credential ID | Type | Permissions |
| --- | --- | --- |
| `github-read-token` | Secret text | Read Actions artifacts and attestations in this repository |
| `ghcr-readonly` | Username/password | GHCR username and a token with `read:packages` |

The GitHub workflow passes the context names into Jenkins as build parameters. Use the exact names returned by `kubectl config get-contexts`. The Jenkins scripts always select those contexts explicitly; they do not rely on whichever context happens to be active. The isolated agent also needs registry pull access from its cluster nodes, or the GHCR package must be public.

The GitHub notification passes the repository, workflow run ID, and commit. Jenkins downloads the `release-evidence-<commit>` artifact from that run; it never accepts a caller-supplied image repository or tag. Configure the `JENKINS_*` Actions secrets above to enable automatic triggering.

## Run the Kind and Kyverno lab

Create the local cluster and install Kyverno:

```sh
make kind-setup
```

Render and install policies for your GitHub repository, then deploy a digest from a successful build:

```sh
make kind-policies REPOSITORY=OWNER/REPO
make local-deploy IMAGE=ghcr.io/OWNER/REPO@sha256:YOUR_64_CHARACTER_DIGEST
make admission-test IMAGE=ghcr.io/OWNER/REPO@sha256:YOUR_64_CHARACTER_DIGEST
```

The registry package must be public for an unauthenticated Kind cluster. For a private package, configure an `imagePullSecret` in the `staging` namespace and Kyverno registry credentials before deploying.

Test the enforcement by submitting an unsigned or tag-based image in `staging`; Kyverno should deny admission. A successful workload must use the signed digest from the authorized `main` workflow.

The test expects the authorized image to be admitted and tag-based, privileged, and unapproved-registry workloads to be denied.

## Repository map

- `.github/workflows/`: contract validation and trusted image build/release.
- `src/`, `test/`, and `Dockerfile`: reference app and tests.
- `security/schemas/`: release manifest contract and fixtures.
- `security/opa/`: release decision policy and tests.
- `security/kyverno/`: runtime image and pod admission policies.
- `jenkins/`: independent verification, staging, policy, approval, and promotion.
- `deploy/`: Kind cluster and staging/production manifests.
- `docs/`: architecture, threat model, and attack tests.

## What this lab does not claim

GitHub's provenance attestation identifies the workflow execution and artifact digest. This project does not claim SLSA Build Level 3: that requires a hardened, trusted builder design beyond generating an attestation. Jenkins and Kubernetes controls also depend on the credentials, cluster identities, and branch protections you configure in your own accounts.
