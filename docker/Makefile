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
	@docker tag ${DOCKER_REPOSITORY}:latest ${DOCKER_REGISTRY_URL}/${DOCKER_REPOSITORY}:${COMMIT_SHA}
	@docker tag ${DOCKER_REPOSITORY}:latest ${DOCKER_REGISTRY_URL}/${DOCKER_REPOSITORY}:latest

	@echo "\n === 🚀 Pushing into repository\n"
	docker push ${DOCKER_REGISTRY_URL}/${DOCKER_REPOSITORY}:${COMMIT_SHA}
	docker push ${DOCKER_REGISTRY_URL}/${DOCKER_REPOSITORY}:latest
	@echo "\n === ✅ Done"
.PHONY:push