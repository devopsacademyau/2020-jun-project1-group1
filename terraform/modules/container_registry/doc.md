# Module Objective

This module will create the ECR repository registry for the docker wordpress image.

> The default repository name is **devops-wordpress**. It can be replaced with the input variable `repository_name`.

## Module Usage

```hcl
module "container_registry" {
    source = "./modules/container_registry"
    repository_name = "devops-wordpress"
}
```

Example of **`outputs.tf`** file:

```hcl
output "registry" {
    value = module.container_registry.ecr_repository
}

```

Where the value will contains the object:

```hcl
registry = {
    "arn" = "arn:aws:ecr:ap-southeast-2:097922957316:repository/devops-wordpress"
    "id" = "devops-wordpress"
    "name" = "devops-wordpress"
    "repository_url" = "097922957316.dkr.ecr.ap-southeast-2.amazonaws.com/devops-wordpress"
}
```

## Connecting to ECR

The ECR is private so it is necessary to generate an authentication token to provide to the docker client.
We can do that with the command below:

```bash
aws ecr get-login-password \
	--region ${AWS_REGION} \
	| docker login \
	--username AWS \
	--password-stdin ${DOCKER_REGISTRY_URL}
```

The first command `aws ecr get-login-password` will use the default aws profile to get the authentication token.
The output of this command will be passed in to `docker login` command.

## Pulling and Pushing Images

Once that we connect to the ECR, now we can push/pull images as we normally do using the docker client commands: `docker push` and `docker pull`.

For the docker push to work, the image should be tagged with the repository path like:

```bash
docker tag devops-wordpress:latest 097922957316.dkr.ecr.ap-southeast-2.amazonaws.com/devops-wordpress:f5bcbb2
```

* Where `f5bcbb2` is the commit sha
* The number `097922957316` is the aws account id where the image from the ECR repository.

### To push the image

```bash
docker push 097922957316.dkr.ecr.ap-southeast-2.amazonaws.com/devops-wordpress:f5bcbb2
```

### To pull the image

```bash
docker pull 097922957316.dkr.ecr.ap-southeast-2.amazonaws.com/devops-wordpress:f5bcbb2
```