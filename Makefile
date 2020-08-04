-include .env

DOCKER_RUNNER ?= docker-compose run --rm
C_GREEN ?= \e[32m
C_RESET ?= \e[0m

AWS_DEFAULT_REGION ?= $(shell cat ~/.aws/config | grep -m 1 region | sed 's/region = //')
AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query "Account" --output text)
DOCKER_REGISTRY_URL ?= ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

docs-terraform:
	@scripts/update-terraform-docs.sh
.PHONY:docs-terraform

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