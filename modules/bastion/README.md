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
| [aws_iam_instance_profile.bastion_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.bastion_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.bastion_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bastion_ec2_AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bastion_ec2_CloudWatchAgentServerPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bastion_ec2_bastion_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.bastion_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.bastion-ingress-cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.bastion-ingress-prefix](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.bastion-ingress-secgrp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_role.bastion_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [template_cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
| [template_file.ds_agent](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | n/a | `string` | n/a | yes |
| <a name="input_az_map"></a> [az\_map](#input\_az\_map) | n/a | `map(any)` | <pre>{<br>  "0": "a",<br>  "1": "b",<br>  "2": "c"<br>}</pre> | no |
| <a name="input_bastion"></a> [bastion](#input\_bastion) | n/a | <pre>object({<br>    enable               = optional(bool, true)<br>    ami_id               = string<br>    instance_type        = optional(string, "t3.medium")<br>    public_access        = optional(bool, true)<br>    attach_eip           = optional(bool, false)<br>    subnet_ids           = list(string)<br>    generate_private_key = optional(bool, true)<br>    private_key_path     = optional(string, "")<br>    public_key_path      = optional(string, "")<br>    hosts_number         = optional(number, 1)<br>    http_proxy           = optional(string, "")<br>    https_proxy          = optional(string, "")<br>    no_proxy             = optional(string, "")<br>    // cli installation variables<br>    kubectl_version  = optional(string, "1.22.6/2022-03-09")<br>    helm_version     = optional(string, "v3.9.2")<br>    helmfile_version = optional(string, "0.145.2")<br>  })</pre> | n/a | yes |
| <a name="input_bastion_secgrp_ingress_cidr"></a> [bastion\_secgrp\_ingress\_cidr](#input\_bastion\_secgrp\_ingress\_cidr) | n/a | <pre>list(object({<br>    cidrs       = list(string)<br>    from_port   = number<br>    to_port     = number<br>    description = string<br>  }))</pre> | `[]` | no |
| <a name="input_bastion_secgrp_ingress_prefix_list"></a> [bastion\_secgrp\_ingress\_prefix\_list](#input\_bastion\_secgrp\_ingress\_prefix\_list) | n/a | <pre>list(object({<br>    prefix_list_ids = list(string)<br>    from_port       = number<br>    to_port         = number<br>    description     = string<br>  }))</pre> | `[]` | no |
| <a name="input_bastion_secgrp_ingress_secgrp"></a> [bastion\_secgrp\_ingress\_secgrp](#input\_bastion\_secgrp\_ingress\_secgrp) | n/a | <pre>list(object({<br>    secgrp_id   = string<br>    from_port   = number<br>    to_port     = number<br>    description = string<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"ap-southeast-1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion-host"></a> [bastion-host](#output\_bastion-host) | n/a |
| <a name="output_bastion-host-public-ip"></a> [bastion-host-public-ip](#output\_bastion-host-public-ip) | n/a |
| <a name="output_bastion-iam_role_arn"></a> [bastion-iam\_role\_arn](#output\_bastion-iam\_role\_arn) | n/a |
| <a name="output_bastion_instance_id"></a> [bastion\_instance\_id](#output\_bastion\_instance\_id) | n/a |
| <a name="output_bastion_sg_id"></a> [bastion\_sg\_id](#output\_bastion\_sg\_id) | n/a |
<!-- END_TF_DOCS -->