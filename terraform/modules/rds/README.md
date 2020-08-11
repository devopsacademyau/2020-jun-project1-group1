## Module responsible for handling the database

For now, until other modules are ready, I had to implement a few resources myself. These resources will later be created by different modules.

### TODO:

- replace module VPC by the project's main VPC
- replace the module subnets by the project's subnets
- update security group rules accordingly
- implement random passwords with SSM

## Required Inputs

The following input variables are required:

### private\_subnets

Description: the list of subnets / availability zones for the rds database

Type: `list(string)`

### vpc

Description: the vpc id for the aurora database

Type:

```hcl
object({
      id = string
      cidr_block = string
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### project

Description: the project name to add as preffix for some resources

Type: `string`

Default: `"devops-wordpress"`

## Outputs

No output.