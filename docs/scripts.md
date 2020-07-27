# Introduction

## docs-terraform

Usage:

Go to the root directory and run:

```bash
make docs-terraform
```

This script will generate the terraform module documentation based on your input/output variables.

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

This script will:
- format the document as `markdown document`
- inject the content of `doc.md` into `README.md`
- hide the sections: `providers` and `requirements`