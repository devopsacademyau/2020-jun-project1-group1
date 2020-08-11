<!-- Start Document Outline -->

* [Workflows](#workflows)
	* [Build Push Wordpress](#build-push-wordpress)
* [Deploy Wordpress](#deploy-wordpress)
* [Local test](#local-test)

<!-- End Document Outline -->

## Workflows

### Build Push Wordpress

> This job will build a new docker image for the wordpress application and push it to ECR registry using the commit sha as label.

- Trigger on: **pull_request**
- Conditions: **changes on path `docker/**/*`**

File: [on-pr-build-wp.yml](../.github/workflows/on-pr-build-wp.yml)

## Deploy Wordpress

> This job will deploy the latest image created to ECS

- Trigger on: **push to master**
- Conditions: **changes on path `docker/**/*`**

File: [on-push-deploy-wp.yml](../.github/workflows/on-push-deploy-wp.yml)

## Local test

For local testing, we are using [nektos/act](https://github.com/nektos/act) which provide a slim environment with the basic github actions features.
Please follow the [installation instrunction](https://github.com/nektos/act#installation) to set it up in your machine.

The command execution can be a bit verbose since we might need to change map the environment to use 3M properly. Hence, we added extra instructions in the main Makefile to trigger the workflows.

Commands available:

- `make ga-test-pr-build-wp`: this command will trigger the workflow [Build Push Wordpress](#build-push-wordpress)
- `make ga-test-push-deploy-wp`: this command will trigger the workflow [Deploy Wordpress](#deploy-wordprews)

We can pass environment and secrets variable to the workflow with the files `.github/.env` and `.github/secrets`, respectively. Please refer for the [template files](../.github/templates) for more details.