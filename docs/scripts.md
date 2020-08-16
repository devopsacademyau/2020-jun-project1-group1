# Introduction

<!-- Start Document Outline -->

* [Global](#global)
	* [kick-n-run](#kick-n-run)
	* [pull-required-images](#pull-required-images)
	* [docs-terraform](#docs-terraform)
* [Application: Docker/ECR](#application-dockerecr)
	* [ecr-login](#ecr-login)
	* [build-wp](#build-wp)
	* [push-wp](#push-wp)
	* [update-wp](#update-wp)
	* [deploy-wp](#deploy-wp)
* [Development: Github Actions](#development-github-actions)
	* [ga-test-env-files](#ga-test-env-files)
	* [ga-test-pr-build-wp](#ga-test-pr-build-wp)
	* [ga-test-push-deploy-wp](#ga-test-push-deploy-wp)
* [Infrastructure: Terraform](#infrastructure-terraform)
	* [tf-ci-plan](#tf-ci-plan)
	* [tf-ci-apply](#tf-ci-apply)
	* [tf-ci-remove](#tf-ci-remove)
	* [tf-all](#tf-all)
* [AWS](#aws)
	* [aws-caller-identity](#aws-caller-identity)
	* [wait-lb](#wait-lb)

<!-- End Document Outline --> 

# Global

## kick-n-run

Kick off the infrastructure and application projects in one command.

This command will execute the following tasks sequentially:

1. **Initialise** the terraform modules (`terraform init`)

2. **Create** the **ECR container registry** for the docker image (`terraform apply -auto-approve -var-file=main.tfvars -target=module.container_registry`)

3. **Build** a fresh copy of the wordpress image and **push** it to the ECR created in step 2. (`make update-wp`)

4. **Create** the rest of the infrastructure modules

5. **Wait until the Load Balancer** is provisioned and an extra time for the target group listeners to be ready. (`make wait-lb`)

**Usage:**

```bash
make kick-n-run

# accept the confirmation typing "y"
```

**Requirements:**

- docker client

## pull-required-images

Check for the required images used during the other commands and pull them if they are not present.

It checks first if the image is pulled or not, so it is safe to call it multiple times.

Images pulled:

- [amazon/aws-cli](https://hub.docker.com/r/amazon/aws-cli)
- [hashicorp/terraform](https://hub.docker.com/r/hashicorp/terraform)
- [stedolan/jq](https://hub.docker.com/r/stedolan/jq)

**Usage:**

```bash
make pull-required-images
```

## docs-terraform

This script will generate the terraform module documentation based on your input/output variables.

**Usage:**

```bash
make docs-terraform
```

It uses [terraform-docs](https://github.com/terraform-docs/terraform-docs) to read `.tf` files and generate the document.

_The script use the docker image with the bin installed so you don't need to install nothing in your machine._

> This script will loop though `terraform/modules` directory and **create/replace** the file a `README.md` for every module.

You can customize the output with a config file. Follow [this link](https://github.com/terraform-docs/terraform-docs/blob/master/docs/CONFIG_FILE.md) for more details.

Here a sample file `.terraform-docs.yml` file:

```yaml
formatter: markdown document
header-from: doc.md

sections:
  hide:
    - providers
    - requirements
```

**This script will:**
- format the document as `markdown document`
- inject the content of `doc.md` into `README.md`
- hide the sections: `providers` and `requirements`

# Application: Docker/ECR

## ecr-login

Authenticate the docker client with the ECR registry.

**Usage:**

```bash
make ecr-login
```

**Requirements:**

- docker client

**Environment variables**

| Name                     | Description                              |
|--------------------------|------------------------------------------|
| **AWS_DEFAULT_REGION**  | the default aws region where the ECR is located. |
| **DOCKER_REGISTRY_URL** | the repository url where the docker image is located <br /> Example: `AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/REPOSITORY_NAME` |

## build-wp

Build a new docker image

**Usage:**

```bash
make build-wp
```

**Requirements:**

- docker client

**Environment variables**

| Name                   | Description                              |
|------------------------|------------------------------------------|
| **DOCKER_REPOSITORY** | the name of the repository used to retrieve the images pushed into the repository. |

## push-wp

Push the recent built image to the ECR repository.

> It will authenticate with the ECR first before run this command: `make ecr-login`

The image will be tagget using the `repo commit sha` and `latest` alias. It will also use the ECR repository prefix. For example:

```
097922957456.dkr.ecr.ap-southeast-2.amazonaws.com/devops-wp:6eb88c0
```

**Requirements:**

- docker client

**Environment variables:**

| Name                     | Description                              |
|--------------------------|------------------------------------------|
| **DOCKER_REPOSITORY**   | the name of the repository used to retrieve the images pushed into the repository. |
| **AWS_DEFAULT_REGION**  | the default aws region where the ECR is located. |
| **DOCKER_REGISTRY_URL** | the repository url where the docker image is located <br /> Example: `AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/REPOSITORY_NAME` |


## update-wp

Execute the commands in order:

- [ecr-login](#ecr-login)
- [build-wp](#build-wp)
- [push-wp](#push-wp)

## deploy-wp

It will create a new ECS task definition and trigger the rolling update of the tasks.

**Usage:**

```bash
# in the root directory
make deploy-wp
```

**List of operations:**

1. Fetch the latest task definition deployed into the ECS. So any update in the task definition url will be reused for the next deployment.
2. Fetch the latest image deployed into the ECR Repository.
3. Update the `task-definition.json` with the new image tag.
4. Register the new task-definition with the ECS.
5. Update the ECS service with the new task-definition revision and force the deploment of new tasks.

**Requirements:**

- docker client
- AWS CLI
- sed

**Environment variables:**

| Name                     | Description                              |
|--------------------------|------------------------------------------|
| **PROJECT_NAME** | the name of the project, used to locate the ECS service for the task definition registration. |
| **DOCKER_REPOSITORY**   | the name of the repository used to retrieve the images pushed into the repository. |
| **DOCKER_REGISTRY_URL** | the repository url where the docker image is located <br /> Example: `AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/REPOSITORY_NAME` |

# Infrastructure: Terraform

## tf-ci-plan

Initialise the terraform modules and execute the terraform plan.
The plan will be output as `terraform-plan` inside the `terraform` folder.

It will use the file `terraform/main.tfvars` for input variables.

**Usage:**

```bash
make tf-ci-plan
```

**Requirements:**

- docker client

## tf-ci-apply

Run terraform apply (with auto-approve) using the terraform plan file `terraform-plan`.

It will use the file `terraform/main.tfvars` for input variables.

**Usage:**

```bash
make tf-ci-apply
```

**Requirements:**

- docker client

## tf-ci-remove

Run terraform destroy (with auto-approve) using the `terraform/main.tfvars` as input variables

```bash
make tf-ci-remove
```

**Requirements:**

- docker client

## tf-all

Run [tf-ci-plan](#tf-ci-plan) and [tf-ci-apply](#tf-ci-apply)

**Usage:**

```bash
make tf-all
```

# AWS

## aws-caller-identity

Check the identity of the AWS user profile. Used mostly for test/debugging purposes.

**Usage:**

```bash
make aws-caller-identity
```

## wait-lb

Wait until the Load Balancer is ready to receive requests.

> 🧯 **TODO:**  change the code due to S3 state compatibility

# Development: Github Actions

## ga-test-env-files

This command will check that the following files exists in `.github`:

- **secrets:** key-value field with secrets
- **.env:** key-value with list of environment variables

> It will exit an error if those files do not exits.

## ga-test-pr-build-wp

Simulate github action execution when:

- a `pull-request` to `merge` was created
- changes were made in `docker` folder

```bash
make ga-test-pr-build-wp
```

**Workflow:** [on-pr-build-wp.yml](../.github/workflows/on-pr-build-wp.yml)

## ga-test-push-deploy-wp

Simulate github action execution when:

- a `push` to `merge` was initiated
- changes were made in `docker` folder

```bash
make ga-test-push-deploy-wp
```

**Workflow:** [on-push-deploy-wp.yml](../.github/workflows/on-push-deploy-wp.yml)