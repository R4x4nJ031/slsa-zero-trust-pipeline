.PHONY: test build scan scan-config run policy kind-cluster kind-kyverno kind-setup kind-policies local-deploy admission-test

IMAGE ?= slsa-zero-trust-pipeline:local
REPOSITORY ?=

test:
	@bash -n scripts/*.sh test/*.sh jenkins/scripts/*.sh
	@./test/validate-release-manifest.sh
	@node --test test/*.test.js

build:
	docker build --tag "$(IMAGE)" .

scan:
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(HOME)/.cache/trivy:/root/.cache/" \
		aquasec/trivy:0.76.2 image \
		--severity CRITICAL,HIGH --ignore-unfixed --exit-code 1 "$(IMAGE)"

scan-config:
	docker run --rm \
		-v "$(CURDIR):/workspace" -w /workspace \
		aquasec/trivy:0.76.2 config \
		--severity HIGH,CRITICAL --exit-code 1 .

run:
	docker run --rm --publish 8080:8080 "$(IMAGE)"

policy:
	@./scripts/test-release-policy.sh

kind-cluster:
	@if kind get clusters | grep -qx slsa-zero-trust; then echo 'Kind cluster already exists'; else kind create cluster --name slsa-zero-trust --config deploy/kind/kind-config.yaml; fi

kind-kyverno:
	helm repo add kyverno https://kyverno.github.io/kyverno/ --force-update
	helm repo update
	helm upgrade --install kyverno kyverno/kyverno --namespace kyverno --create-namespace --wait --timeout 5m

kind-setup: kind-cluster kind-kyverno

kind-policies:
	@./scripts/install-local-policies.sh "$(REPOSITORY)"

local-deploy:
	@./scripts/deploy-local.sh "$(IMAGE)"

admission-test:
	@./scripts/test-admission.sh "$(IMAGE)"
