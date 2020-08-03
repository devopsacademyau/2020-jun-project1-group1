## Required Inputs

The following input variables are required:

### project-name

Description: variable declaration

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### deploy\_nat

Description: n/a

Type: `bool`

Default: `true`

### dnsHostNames

Description: n/a

Type: `bool`

Default: `true`

### dnsSupport

Description: n/a

Type: `bool`

Default: `true`

### instanceTenancy

Description: defult or dedicated

Type: `list(string)`

Default:

```json
[
  "default",
  "dedicated"
]
```

### map\_public\_ip1

Description: n/a

Type: `bool`

Default: `true`

### map\_public\_ip2

Description: n/a

Type: `bool`

Default: `true`

### vpcCIDR

Description: VPC network

Type: `string`

Default: `"192.168.0.0/16"`

## Outputs

The following outputs are exported:

### private\_subnets

Description: n/a

### public\_subnets

Description: n/a

### subnet-public-1

Description: n/a

### subnet-public-2

Description: n/a

### vpc\_id

Description: n/a

