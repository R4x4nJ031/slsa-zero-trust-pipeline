package release

default allow = false

allow if {
  input.signature.verified == true
  input.identity.authorized == true
  input.provenance.verified == true
  input.sbom.verified == true
  input.tests.passed == true
  input.image.digest != ""
  input.trivy.critical_count == 0
}

deny contains "signature verification failed" if {
  input.signature.verified != true
}

deny contains "signer identity is not authorized" if {
  input.identity.authorized != true
}

deny contains "provenance verification failed" if {
  input.provenance.verified != true
}

deny contains "SBOM verification failed" if {
  input.sbom.verified != true
}

deny contains "required tests failed" if {
  input.tests.passed != true
}

deny contains "critical vulnerabilities present" if {
  input.trivy.critical_count != 0
}