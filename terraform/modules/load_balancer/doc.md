# Module Objective

This module abstract the creation of an Application Load Balancer, Target Groups, Listeners and Security Groups.

Ideally, someone who would use the `target_group_arn` output from this module to attach to an Autoscalling Group using
`aws_autoscalling_attachment` resource and passing the `autoscalling_group_name`. Please refer for the example below:

```hcl
resource "aws_autoscaling_attachment" "this" {
    autoscaling_group_name = aws_autoscaling_group.devops.id
    alb_target_group_arn = module.load_balancer.target_group_arn
}
```

> This module doens't created the ASG.

The port which the Load Balancer will listen to request can be modified with the input variable `https_enabled`. The default value is true (https enabled), but for testing purposes, it can be disabled.