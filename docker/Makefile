-include .env

COMMIT_SHA ?= $(shell git rev-parse --short HEAD)
AWS_DEFAULT_REGION ?= $(shell cat ~/.aws/config | grep -m 1 region | sed 's/region = //')
AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query "Account" --output text)

DOCKER_REPOSITORY ?= devops-wordpress
DOCKER_REGISTRY_URL ?= ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

C_GREEN ?= \e[32m
C_RESET ?= \e[0m

build:
	@echo "\n === 🏭 Building Wordpress image\n"
	@docker-compose build wordpress
	@echo "\n === ✅ Done"
.PHONY:build

push:
	@echo "\n === 🔖 Tagging image with sha ${C_GREEN}${COMMIT_SHA}${C_RESET}"
	@docker tag devops-wordpress:latest ${DOCKER_REGISTRY_URL}/${DOCKER_REPOSITORY}:${COMMIT_SHA}
	
	@echo "\n === 🚀 Pushing into repository\n"
	docker push ${DOCKER_REGISTRY_URL}/${DOCKER_REPOSITORY}:${COMMIT_SHA}
	@echo "\n === ✅ Done"
.PHONY:push

ecr-login:
	@echo "\n === 🔐 Login to ECR docker registry: ${C_GREEN}${DOCKER_REGISTRY_URL}${C_RESET}\n"

	@aws ecr get-login-password \
		--region ${AWS_DEFAULT_REGION} \
		| docker login \
		--username AWS \
		--password-stdin ${DOCKER_REGISTRY_URL}

	@echo "\n === ✅ Done"
.PHONY:ecr_login

deploy: ecr-login build push
.PHONY: deploy