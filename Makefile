.PHONY: test build run policy kind-cluster kind-policies local-deploy admission-test

test:
	@bash -n scripts/*.sh test/*.sh jenkins/scripts/*.sh
	@./test/validate-release-manifest.sh
	@node --test test/*.test.js

build:
	docker build --tag slsa-zero-trust-pipeline:local .

run:
	docker run --rm --publish 8080:8080 slsa-zero-trust-pipeline:local

policy:
	@./scripts/test-release-policy.sh

kind-cluster:
	kind create cluster --config deploy/kind/kind-config.yaml

kind-policies:
	@./scripts/install-local-policies.sh "$(REPOSITORY)"

local-deploy:
	@./scripts/deploy-local.sh "$(IMAGE)"

admission-test:
	@./scripts/test-admission.sh "$(IMAGE)"
