package release

valid_input := {
  "signature": {"verified": true},
  "identity": {"authorized": true},
  "provenance": {"verified": true},
  "sbom": {"verified": true},
  "tests": {"passed": true},
  "image": {"digest": "sha256:abc"},
  "trivy": {"critical_count": 0}
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