.PHONY: test build run policy

test:
	@bash -n scripts/*.sh test/*.sh jenkins/scripts/*.sh
	@./test/validate-release-manifest.sh

build:
	docker build --tag slsa-zero-trust-pipeline:local .

run:
	docker run --rm --publish 8080:8080 slsa-zero-trust-pipeline:local

policy:
	@./scripts/test-release-policy.sh