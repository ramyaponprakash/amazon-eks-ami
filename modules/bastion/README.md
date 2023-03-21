<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.ubuntu_bastion_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_instance.ubuntu_bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.generated_keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.bastion_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [null_resource.wait_for_bastion](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.generated_sshkey](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [template_file.userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az_map"></a> [az\_map](#input\_az\_map) | n/a | `map(any)` | <pre>{<br>  "0": "a",<br>  "1": "b",<br>  "2": "c"<br>}</pre> | no |
| <a name="input_bastion"></a> [bastion](#input\_bastion) | n/a | <pre>object({<br>    enable               = optional(bool, true)<br>    instance_type        = optional(string, "t3.medium")<br>    public_access        = optional(bool, true)<br>    attach_eip           = optional(bool, false)<br>    subnet_ids           = list(string)<br>    generate_private_key = optional(bool, true)<br>    private_key_path     = optional(string, "empty")<br>    public_key_path      = optional(string, "empty")<br>    hosts_number         = optional(number, 1)<br>    iam_role             = string<br>    ssh_cidr_blocks      = optional(list(string))<br>    ssh_prefix_list_ids  = optional(list(string))<br><br>    // cli installation variables<br>    kubectl_version  = optional(string, "1.22.6/2022-03-09")<br>    helm_version     = optional(string, "v3.9.2")<br>    helmfile_version = optional(string, "0.145.2")<br>  })</pre> | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"ap-southeast-1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion-host"></a> [bastion-host](#output\_bastion-host) | n/a |
| <a name="output_bastion-host-public-ip"></a> [bastion-host-public-ip](#output\_bastion-host-public-ip) | n/a |
| <a name="output_bastion_eip_id"></a> [bastion\_eip\_id](#output\_bastion\_eip\_id) | n/a |
| <a name="output_bastion_instance_id"></a> [bastion\_instance\_id](#output\_bastion\_instance\_id) | n/a |
| <a name="output_bastion_sg_id"></a> [bastion\_sg\_id](#output\_bastion\_sg\_id) | n/a |
| <a name="output_generated_ssh_private_key"></a> [generated\_ssh\_private\_key](#output\_generated\_ssh\_private\_key) | n/a |
| <a name="output_generated_ssh_public_key"></a> [generated\_ssh\_public\_key](#output\_generated\_ssh\_public\_key) | n/a |
<!-- END_TF_DOCS -->