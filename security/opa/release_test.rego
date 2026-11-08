package release

valid_input := {
  "signature": {"verified": true},
  "identity": {"authorized": true},
  "provenance": {"verified": true},
  "sbom": {"verified": true},
  "tests": {"passed": true},
  "dast": {"passed": true},
  "image": {"digest": "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
  "trivy": {"critical_count": 0, "high_count": 0}
}

test_valid_release if {
  allow with input as valid_input
}

test_unsigned_release_denied if {
  not allow with input as object.union(valid_input, {"signature": {"verified": false}})
  "signature verification failed" in deny with input as object.union(valid_input, {"signature": {"verified": false}})
}

test_critical_release_denied if {
  not allow with input as object.union(valid_input, {"trivy": {"critical_count": 1}})
}

test_high_release_denied if {
  not allow with input as object.union(valid_input, {"trivy": {"critical_count": 0, "high_count": 1}})
}

test_dast_failure_denied if {
  not allow with input as object.union(valid_input, {"dast": {"passed": false}})
  "DAST baseline failed" in deny with input as object.union(valid_input, {"dast": {"passed": false}})
}

test_invalid_digest_denied if {
  not allow with input as object.union(valid_input, {"image": {"digest": "latest"}})
  "image digest is missing or invalid" in deny with input as object.union(valid_input, {"image": {"digest": "latest"}})
}
