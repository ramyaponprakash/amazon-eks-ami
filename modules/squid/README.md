<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_attachment.sdx_intra_prd_nlb_jaeger_att](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [aws_autoscaling_group.squid_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_template.squid_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.squid_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.squid_nlb_listener_3128](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.squid_target_group_3128](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.route53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.squidproxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.squidproxy-ingress-cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.squidproxy-ingress-secgrp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [template_file.squid_userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"ap-southeast-1"` | no |
| <a name="input_squid"></a> [squid](#input\_squid) | n/a | <pre>object({<br>    enable         = optional(bool, true)<br>    instance_type  = optional(string, "t3.medium")<br>    subnet_ids     = list(string)<br>    subnet_gw_ids  = list(string)<br>    zone_id        = string<br>    ami_squid      = string<br>    record_name    = string<br>    squid_key_name = string<br>    iam_role       = string<br>    kms_key_id     = string<br>  })</pre> | n/a | yes |
| <a name="input_squid_secgrp_ingress_cidr"></a> [squid\_secgrp\_ingress\_cidr](#input\_squid\_secgrp\_ingress\_cidr) | n/a | <pre>list(object({<br>    cidrs       = list(string)<br>    from_port   = number<br>    to_port     = number<br>    description = string<br>  }))</pre> | `[]` | no |
| <a name="input_squid_secgrp_ingress_secgrp"></a> [squid\_secgrp\_ingress\_secgrp](#input\_squid\_secgrp\_ingress\_secgrp) | n/a | <pre>list(object({<br>    secgrp_id   = string<br>    from_port   = number<br>    to_port     = number<br>    description = string<br>  }))</pre> | `[]` | no |
| <a name="input_vpc_cidr_pri"></a> [vpc\_cidr\_pri](#input\_vpc\_cidr\_pri) | n/a | `string` | n/a | yes |
| <a name="input_vpc_cidr_sec"></a> [vpc\_cidr\_sec](#input\_vpc\_cidr\_sec) | n/a | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | If network.create\_vpc=false, it must be provided | `string` | `""` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | n/a | `string` | n/a | yes |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | n/a | <pre>list(object({<br>    cidr       = string<br>    enable_elb = number<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->