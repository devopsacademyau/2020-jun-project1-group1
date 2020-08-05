-include .env

DOCKER_RUNNER ?= docker-compose run --rm
C_GREEN ?= \e[32m
C_RED ?= \e[31m
C_RESET ?= \e[0m

AWS_DEFAULT_REGION ?= $(shell cat ~/.aws/config | grep -m 1 region | sed 's/region = //')
AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query "Account" --output text)
DOCKER_REGISTRY_URL ?= ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
DOCKER_REPOSITORY ?= devops-wordpress

docs-terraform:
	@scripts/update-terraform-docs.sh
.PHONY:docs-terraform

build-wp:
	@cd docker && DOCKER_REPOSITORY=${DOCKER_REPOSITORY} $(MAKE) build
.PHONY: build-wp

push-wp:
	@export DOCKER_REPOSITORY=${DOCKER_REPOSITORY}
	@cd docker && $(MAKE) push
.PHONY: push-wp

deploy-wp:
	@export DOCKER_REPOSITORY=${DOCKER_REPOSITORY}
	@export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
	@scripts/deploy-wp.sh
.PHONY: deploy-wp

ecr-login:
	@echo "\n === 🔐 Login to ECR docker registry: ${C_GREEN}${DOCKER_REGISTRY_URL}${C_RESET}\n"

# check if the amazon aws was pulled, if not, pull it first to avoid error in the docker login.
	@if [ -z "$(shell docker image ls --filter=reference=amazon/aws-cli -q)" ]; then\
		docker-compose pull aws;\
	fi

	@$(DOCKER_RUNNER) aws ecr get-login-password \
		--region ${AWS_DEFAULT_REGION} \
		| docker login \
		--username AWS \
		--password-stdin ${DOCKER_REGISTRY_URL}

	@echo "\n === ✅ Done"
.PHONY:ecr_login

ga-test-env-files:
	@if [ ! -f ".github/secrets" ]; then \
		echo "${C_RED}must create secrets file in .github/secrets"; \
		echo "check template in .github/templates/secrets.template"; \
		exit 1; \
	fi

	@if [ ! -f ".github/.env" ]; then \
		echo "${C_RED}must create secrets file in .github/.env"; \
		echo "check template in .github/templates/.env.template"; \
		exit 1; \
	fi
.PHONY:ga-test-env-files

ga-test-pr-build-wp: ga-test-env-files
	act pull_request \
		--job build_push_wp \
		--secret-file .github/secrets \
		--env-file .github/.env \
		-P ubuntu-20.04=flemay/musketeers
.PHONY:ga-test-pr-build-wp

ga-test-push-deploy-wp: ga-test-env-files
	act push \
		--job deploy_wp \
		--secret-file .github/secrets \
		--env-file .github/.env \
		-P ubuntu-20.04=flemay/musketeers
.PHONY:ga-test-push-wp