# Attack test cases

| ID | Attack | Expected defense |
| --- | --- | --- |
| A01 | Pull request modifies the release workflow | No release credentials are available to the pull request job |
| A02 | Jenkins receives a forged manifest | Independent GHCR and Cosign verification rejects it |
| A03 | Mutable image tag is substituted | Jenkins and Kyverno require a sha256 digest |
| A04 | Unsigned image is deployed directly | Kyverno admission denies the workload |
| A05 | Image is signed by an unauthorized workflow | Cosign identity constraints deny verification |
| A06 | Provenance is absent or forged | Jenkins and Kyverno require SLSA provenance |
| A07 | Privileged workload is submitted | Kyverno rejects the pod |
| A08 | Scanner fails but returns no findings | Fail-closed policy treats missing results as a release failure |