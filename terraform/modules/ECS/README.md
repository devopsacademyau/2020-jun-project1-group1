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