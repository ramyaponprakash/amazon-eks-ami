<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.pub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private_elb_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eip.nat_gw_public_ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eip) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az_map"></a> [az\_map](#input\_az\_map) | n/a | `map(any)` | <pre>{<br>  "0": "a",<br>  "1": "b",<br>  "2": "c"<br>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name will be tagged to vpc and subnets for auto discovery by elb and ingress controller | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Base config to enable/disable module. create\_vpc=false will skip vpc creation. | <pre>object({<br>    enable     = optional(bool, false)<br>    create_vpc = optional(bool, true)<br>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"ap-southeast-1"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_excluded_zone_names"></a> [vpc\_excluded\_zone\_names](#input\_vpc\_excluded\_zone\_names) | n/a | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | If network.create\_vpc=false, it must be provided | `string` | `""` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | n/a | `string` | n/a | yes |
| <a name="input_vpc_nat_gw_eip_allocation_ids"></a> [vpc\_nat\_gw\_eip\_allocation\_ids](#input\_vpc\_nat\_gw\_eip\_allocation\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_vpc_private_elb_subnets"></a> [vpc\_private\_elb\_subnets](#input\_vpc\_private\_elb\_subnets) | n/a | <pre>list(object({<br>    cidr       = string<br>    enable_elb = number<br>  }))</pre> | `[]` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | n/a | <pre>list(object({<br>    cidr       = string<br>    enable_elb = number<br>  }))</pre> | <pre>[<br>  {<br>    "cidr": "10.0.0.0/24",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "10.0.1.0/24",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "10.0.2.0/24",<br>    "enable_elb": 0<br>  }<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | n/a | <pre>list(object({<br>    cidr       = string<br>    enable_elb = number<br>  }))</pre> | <pre>[<br>  {<br>    "cidr": "10.0.10.0/24",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "10.0.11.0/24",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "10.0.12.0/24",<br>    "enable_elb": 0<br>  }<br>]</pre> | no |
| <a name="input_vpc_secondary_cidr_blocks"></a> [vpc\_secondary\_cidr\_blocks](#input\_vpc\_secondary\_cidr\_blocks) | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_elb_subnet_ids"></a> [private\_elb\_subnet\_ids](#output\_private\_elb\_subnet\_ids) | n/a |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | n/a |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->