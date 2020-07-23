<!-- Start Document Outline -->

* [Introduction](#introduction)
* [Environment variables](#environment-variables)
	* [.env file template:](#env-file-template)
* [make instructions](#make-instructions)
	* [build](#build)
	* [push](#push)
	* [ecr-login](#ecr-login)
	* [deploy](#deploy)
* [Local Tests](#local-tests)

<!-- End Document Outline -->

# Introduction

This document describes the environment variables used for the wordpress image and some make instruction which can be used for automation.

- [Wordpress Dockerfile](../docker/Dockerfile)
- [Makefile](../docker/Makefile)

The base wordpress image used for this project will be [5.4-php7.2-apache](https://hub.docker.com/_/wordpress/).

# Environment variables

| Key                   | Description                              | Mandatory                                |
|-----------------------|------------------------------------------|------------------------------------------|
| **WORDPRESS_DB_HOST**           | The database host name for the Wordpress to connect.<br>***Example:*** `db` | **true**                                     |
| **WORDPRESS_DB_USER**           | The database user name for the Wordpress to connect.<br>***Example:*** `wordpress-user` | **true**                                     |
| **WORDPRESS_DB_PASSWORD**       | The database user password for the Wordpress to connect.<br>***Example:*** `wordpress-secret` | **true**                                     |
| **WORDPRESS_DB_NAME**           | The database name for the Wordpress to connect.<br>***Example:*** `wordpress-db` | **true**                                     |
| **DOCKER_REPOSITORY** | The name of the repository which the image is build and it will be pushed.<br>***Example:*** `devops-wordpress` | **false**<br>***default:*** `devops-wordpress`     |
| **AWS_ACCOUNT_ID**    | The AWS Account Id used to login to ECR and to tag and push the image.<br>***Example:*** `027422937416` | **false**<br>***default:*** it will read from the aws default profile if not specified |
| **AWS_REGION**        | The AWS region where the ECR is located.<br>***Example:*** `ap-southeast-2` | **false**<br>***default:*** it will read from the aws default profile it not specified |

## **.env** file template:

The `.env` should be located in the same directory of `docker-compose` and `Makefile`. Alternatively, those variables can be set in the local machine.

```bash
WORDPRESS_DB_HOST=
WORDPRESS_DB_USER=
WORDPRESS_DB_PASSWORD=
WORDPRESS_DB_NAME=
DOCKER_REPOSITORY=
AWS_ACCOUNT_ID=
AWS_REGION=
```

# `make` instructions

Make instruction will be using environment variables to execute the commands.

Environment variables will be evaluated in the following order, with later source taking precedence over earlier ones:

- **System environment**, set using `export` command
- **`.env` file** located in the same folder that `Makefile`
- At the time that the command is executed. Ex. `AWS_ACCOUNT_ID=027422937416 make ecr-login`

### build

Build a new docker image:

```bash
make build
```

Required variables:

- **DOCKER_REPOSITORY**

### push

Tag the latest image with the commit sha and push it to the container registry (ECR).

```bash
make push
```

*The commit sha will be generated at run time using the instruction: `git rev-parse --short HEAD`*

Required variables:

- **AWS_ACCOUNT_ID**
- **AWS_REGION**
- **DOCKER_REPOSITORY**

### ecr-login

Using the default aws profile, authenticate with the ECR registry and add the authentication token to `docker login`.

```bash
make ecr-login
```

Required variables:

- **AWS_ACCOUNT_ID**
- **AWS_REGION**
- **DOCKER_REPOSITORY**

## deploy

Execute the following commands in order:

1. [**build**](#build)
2. [**push**](#push)
3. [**ecr-login**](#ecr-login)

# Local Tests

The [docker-compose](../docker/docker-compose.yaml) file, which is used to build the docker image, can be used for local tests running the command:

```bash
# to initiate the local server and run the wordpress and mysql containers
$ docker-compose up 
```