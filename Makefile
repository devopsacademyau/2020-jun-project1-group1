-include .env

DOCKER_RUNNER ?= docker-compose run --rm
C_GREEN ?= \e[32m
C_RED ?= \e[31m
C_RESET ?= \e[0m

AWS_DEFAULT_REGION ?= $(shell cat ~/.aws/config | grep -m 1 region | sed 's/region = //')
AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query "Account" --output text)
DOCKER_REGISTRY_URL ?= ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
DOCKER_REPOSITORY ?= devops-wordpress
PROJECT_NAME ?= devops-wordpress

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
	$(DOCKER_RUNNER) \
		-e PROJECT_NAME=${PROJECT_NAME} \
		-e DOCKER_REPOSITORY_URL="${DOCKER_REGISTRY_URL}/${DOCKER_REPOSITORY}" \
		-e DOCKER_REPOSITORY_NAME=${DOCKER_REPOSITORY} \
		--entrypoint /bin/sh \
		aws \
		scripts/deploy-wp.sh
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

update-wp: ecr-login build-wp push-wp
.PHONY:update-wp

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

test-aws:
	$(DOCKER_RUNNER) aws sts get-caller-identity --output json
.PHONY:test-aws


tf-ci-plan:
	@$(DOCKER_RUNNER) ci-terraform init
	@$(DOCKER_RUNNER) ci-terraform plan -var-file="main.tfvars" -out terraform-plan 
.PHONY:tf-ci-plan


tf-ci-apply:
	@$(DOCKER_RUNNER) ci-terraform apply -auto-approve "terraform-plan"
.PHONY:tf-ci-apply


tf-ci-remove:
	@$(DOCKER_RUNNER) ci-terraform destroy -auto-approve -var-file="main.tfvars"
.PHONY:tf-ci-remove

all: 
	make tf-ci-plan
	make tf-ci-apply
.PHONY: all

boot-n-run:
	$(DOCKER_RUNNER) ci-terraform apply -var-file=main.tfvars -target=module.container_registry
	$(MAKE) update-wp
	$(DOCKER_RUNNER) ci-terraform apply -var-file=main.tfvars 
.PHONY:boot-n-run

