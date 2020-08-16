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
S3_BUCKET ?= da-devops-terraform

pull-required-images:
	@if [ -z "$(shell docker image ls --filter=reference=amazon/aws-cli -q)" ]; then\
		docker-compose pull aws;\
	fi

	@if [ -z "$(shell docker image ls --filter=reference=stedolan/jq -q)" ]; then\
		docker-compose pull jq;\
	fi

	@if [ -z "$(shell docker image ls --filter=reference=hashicorp/terraform -q)" ]; then\
		docker-compose pull ci-terraform;\
	fi
.PHONY:pull-required-images

docs-terraform:
	@scripts/update-terraform-docs.sh
.PHONY:docs-terraform

build-wp:
	@cd docker \
		&& DOCKER_REPOSITORY=${DOCKER_REPOSITORY} \
		$(MAKE) build
.PHONY: build-wp

push-wp:
	@cd docker \
		&& DOCKER_REPOSITORY=${DOCKER_REPOSITORY} \
		AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
		DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_URL} \
		$(MAKE) push
.PHONY: push-wp

deploy-wp:
	@$(DOCKER_RUNNER) \
		-e PROJECT_NAME=${PROJECT_NAME} \
		-e DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_URL} \
		-e DOCKER_REPOSITORY=${DOCKER_REPOSITORY} \
		--entrypoint /bin/sh \
		aws \
		scripts/deploy-wp.sh
.PHONY: deploy-wp

ecr-login: pull-required-images
	@echo "\n === 🔐 Login to ECR docker registry: ${C_GREEN}${DOCKER_REGISTRY_URL}${C_RESET}\n"

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

aws-caller-identity:
	@echo "Retrieving AWS caller identity"
	@$(DOCKER_RUNNER) aws sts get-caller-identity --output json
.PHONY:test-aws

tf-backend-storage:
	@echo ">> dynamodb create-table"
	@$(DOCKER_RUNNER) aws dynamodb create-table \
    --table-name ${S3_BUCKET}-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --tags Key=Name,Value=${PROJECT_NAME}-dynamodb

	@echo ">> s3 mb"
	@$(DOCKER_RUNNER) aws s3 mb s3://${S3_BUCKET} --region ap-southeast-2
.PHONY:tf-backend-storage	

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
	
tf-ci-lb:
	@$(DOCKER_RUNNER) aws elbv2 describe-load-balancers --names ${PROJECT_NAME}-lb  --query LoadBalancers[].DNSName --output text
.PHONY:tf-ci-lb

tf-ci-lbarn:
	@$(DOCKER_RUNNER) aws elbv2 describe-load-balancers --names ${PROJECT_NAME}-lb --query LoadBalancers[].LoadBalancerArn --output text 
.PHONY:tf-ci-lbarn


tf-all: 
	make tf-ci-plan
	make tf-ci-apply
.PHONY: tf-all

kick-n-run: pull-required-images
	@echo "${C_GREEN}"
	@echo "This process will kickoff all terraform modules and apply to your AWS account"
	@echo "It will also build and push a fresh docker image for the ECR"
	@echo "The whole process might take up to 7-10min till finish (applying and waiting resource provisioning)"
	@echo "${C_RED}"
	@echo -n "\nContinue? [y/N] If yes, literally kick 🦶 and run 🏃‍♀️🏃‍♂️💨💨\n" && read ans && [ $${ans:-N} = y ]
	@echo "${C_RESET}"

	@$(DOCKER_RUNNER) ci-terraform init 
	@$(DOCKER_RUNNER) ci-terraform apply -auto-approve -var-file=main.tfvars -target=module.container_registry
	$(MAKE) update-wp
	@$(DOCKER_RUNNER) ci-terraform apply -auto-approve -var-file=main.tfvars 
	# $(MAKE) wait-lb
.PHONY:kick-n-run

wait-lb: pull-required-images
	@echo "${C_RED}Waiting until the LB is ready...${C_RESET}"
	@$(DOCKER_RUNNER) aws elbv2 wait load-balancer-available --load-balancer-arns $(make tf-ci-lbarn)
	@sleep 2m

#@echo "${C_RED}Waiting until the Target Groups is ready...${C_RESET}"
#@$(DOCKER_RUNNER) aws elbv2 wait target-in-service --target-group-arn $(shell $(DOCKER_RUNNER) jq -r ".outputs[\"lb-module\"].value.target_group_arn" ./terraform/terraform.tfstate)
	
	@echo "${C_GREEN}Green is good, the LB was provisioned, but the targets might be in registering stage yet.${C_RESET}"
#@echo "\bOpen the browser at http://$(shell $(DOCKER_RUNNER) jq -r ".outputs[\"lb-module\"].value.load_balancer.dns_name" ./terraform/terraform.tfstate)"
	@echo "DNS name outputted below"
	$(MAKE) tf-ci-lb
	@echo "give it a few minutes to boot up"
.PHONY:wait-lb
