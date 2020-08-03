Objectives:

Create a ECS Cluster  
Cluster can be using Fargate or EC2 Instances  
The cluster is high available across 2 AZs  
Hosted in private Zone  
Security Groups are created with least privileges  
IAM roles required are associated with the cluster nodes  
Acceptance Criteria:

ECS cluster is visible from the AWS console  
There is no SG with 0.0.0.0/0  
The cluster can pull images from ECR  
Documentation is updated with information related t the ECS cluster

## Required Inputs

The following input variables are required:

### project-name

Description: variable declaration

Type: `string`

### subnet-public-1

Description: n/a

Type: `any`

### subnet-public-2

Description: n/a

Type: `any`

### target\_group\_arn

Description: n/a

Type: `any`

### vpc\_id

Description: n/a

Type: `any`

## Optional Inputs

The following input variables are optional (have default values):

### image\_id

Description: n/a

Type: `string`

Default: `"ami-0b781a9543e01e880"`

### instance\_type

Description: n/a

Type: `string`

Default: `"t2.micro"`

### max-size

Description: Maximum number of instances in the cluster

Type: `number`

Default: `5`

### min-size

Description: Minimum number of instances in the cluster

Type: `number`

Default: `1`

## Outputs

The following outputs are exported:

### ecs-access-security-group

Description: n/a

