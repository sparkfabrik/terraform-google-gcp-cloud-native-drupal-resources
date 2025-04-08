TERRAFORM_DOCS_IMAGE_TAG ?= 0.20.0

.PHONY: lint tfscan generate-docs

lint:
	docker run --rm -v $${PWD}:/data -t ghcr.io/terraform-linters/tflint --var-file=/data/examples/test.tfvars --recursive

tfsec:
	docker run --rm -it -v "$$(pwd):/src" aquasec/tfsec /src --tfvars-file=/src/examples/test.tfvars

generate-docs: lint
	docker run --rm -u $$(id -u) \
		--volume "$(PWD):/terraform-docs" \
		-w /terraform-docs \
		quay.io/terraform-docs/terraform-docs:$(TERRAFORM_DOCS_IMAGE_TAG) markdown table --config .terraform-docs.yml --output-file README.md --output-mode inject .

# Renovate configuration test
renovate-test:
	@docker run --rm -it \
		-u "0:0" \
		-e LOG_LEVEL=debug \
		-v "$(PWD)":/tmp/app \
		--entrypoint bash \
		renovate/renovate -lc "cp -av /tmp/app /usr/src && cd /usr/src/app && jq 'del(.extends)' /tmp/app/renovate.json >/usr/src/app/renovate.json && renovate --platform=local --dry-run"
