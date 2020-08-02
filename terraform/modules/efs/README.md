Objectives:

Use vpc from network stack
Available in both AZs
Security group allowing only ECS instances to access it
No lifecycle policy
Throughput mode bursting
Performance mode general purpose
No need for encryption
No need for IAM authentication
Add one access point:
Name wordpress
Path /wordpress

Acceptance Criteria:

EFS is available in at least two AZ
I can mount efs volume on an ec2 instance running on private subnet following instructions https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html
I CAN'T mount efs volume from instance on public subnet