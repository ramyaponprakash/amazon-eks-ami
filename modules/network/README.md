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
| [aws_eip.vpc_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_route_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.pub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.vpc_endpoint-secgrp-cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpc_endpoint-secgrp-self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.private_elb_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_sec_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc_endpoint.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecr_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecr_dkr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.elasticloadbalancing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eip.nat_gw_public_ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eip) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az_map"></a> [az\_map](#input\_az\_map) | n/a | `map(any)` | <pre>{<br>  "0": "a",<br>  "1": "b",<br>  "2": "c"<br>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name will be tagged to vpc and subnets for auto discovery by elb and ingress controller | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Base config to enable/disable module. create\_vpc=false will skip vpc creation. | <pre>object({<br>    enable     = optional(bool, true)<br>    create_vpc = optional(bool, false)<br>    peers = list(object({<br>      destination = string<br>      target      = string<br>    }))<br>    tgw = list(object({<br>      destination = string<br>      target      = string<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"ap-southeast-1"` | no |
| <a name="input_vpc_cidr_pri"></a> [vpc\_cidr\_pri](#input\_vpc\_cidr\_pri) | n/a | `string` | n/a | yes |
| <a name="input_vpc_cidr_sec"></a> [vpc\_cidr\_sec](#input\_vpc\_cidr\_sec) | n/a | `string` | `""` | no |
| <a name="input_vpc_eip"></a> [vpc\_eip](#input\_vpc\_eip) | n/a | <pre>object({<br>    enable_eip = optional(bool, true)<br>    count      = number<br>  })</pre> | n/a | yes |
| <a name="input_vpc_enable_private"></a> [vpc\_enable\_private](#input\_vpc\_enable\_private) | n/a | `bool` | `false` | no |
| <a name="input_vpc_endpoint_allowed_cidrs"></a> [vpc\_endpoint\_allowed\_cidrs](#input\_vpc\_endpoint\_allowed\_cidrs) | n/a | `list(string)` | `[]` | no |
| <a name="input_vpc_endpoint_subnets"></a> [vpc\_endpoint\_subnets](#input\_vpc\_endpoint\_subnets) | n/a | `list(string)` | `[]` | no |
| <a name="input_vpc_excluded_zone_names"></a> [vpc\_excluded\_zone\_names](#input\_vpc\_excluded\_zone\_names) | Network module will use all available availability zones in the region, adding zones to this list will exclude them. | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | If network.create\_vpc=false, it must be provided | `string` | `""` | no |
| <a name="input_vpc_igw"></a> [vpc\_igw](#input\_vpc\_igw) | n/a | <pre>object({<br>    enable_igw = optional(bool, false)<br>    count      = number<br>  })</pre> | n/a | yes |
| <a name="input_vpc_igw_ids"></a> [vpc\_igw\_ids](#input\_vpc\_igw\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | n/a | `string` | n/a | yes |
| <a name="input_vpc_nat_gateway"></a> [vpc\_nat\_gateway](#input\_vpc\_nat\_gateway) | n/a | <pre>object({<br>    enable = optional(bool, true)<br>  })</pre> | n/a | yes |
| <a name="input_vpc_nat_gw_eip_allocation_ids"></a> [vpc\_nat\_gw\_eip\_allocation\_ids](#input\_vpc\_nat\_gw\_eip\_allocation\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_vpc_nat_gw_ids"></a> [vpc\_nat\_gw\_ids](#input\_vpc\_nat\_gw\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_vpc_private_elb_subnets"></a> [vpc\_private\_elb\_subnets](#input\_vpc\_private\_elb\_subnets) | n/a | <pre>list(object({<br>    cidr       = string<br>    enable_elb = number<br>  }))</pre> | `[]` | no |
| <a name="input_vpc_private_sec_subnets"></a> [vpc\_private\_sec\_subnets](#input\_vpc\_private\_sec\_subnets) | n/a | <pre>list(object({<br>    cidr       = string<br>    enable_elb = number<br>  }))</pre> | <pre>[<br>  {<br>    "cidr": "100.80.29.192/27",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "100.80.29.224/28",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "100.80.29.240/28",<br>    "enable_elb": 0<br>  }<br>]</pre> | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | n/a | <pre>list(object({<br>    cidr       = string<br>    enable_elb = number<br>  }))</pre> | <pre>[<br>  {<br>    "cidr": "10.0.0.0/24",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "10.0.1.0/24",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "10.0.2.0/24",<br>    "enable_elb": 0<br>  }<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | n/a | <pre>list(object({<br>    cidr       = string<br>    enable_elb = number<br>  }))</pre> | <pre>[<br>  {<br>    "cidr": "100.112.110.0/26",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "100.112.110.64/26",<br>    "enable_elb": 1<br>  },<br>  {<br>    "cidr": "100.112.110.128/25",<br>    "enable_elb": 0<br>  }<br>]</pre> | no |
| <a name="input_vpc_sec_enable_cidr"></a> [vpc\_sec\_enable\_cidr](#input\_vpc\_sec\_enable\_cidr) | n/a | `bool` | `false` | no |
| <a name="input_vpc_secondary_cidr_blocks"></a> [vpc\_secondary\_cidr\_blocks](#input\_vpc\_secondary\_cidr\_blocks) | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_elb_subnet_ids"></a> [private\_elb\_subnet\_ids](#output\_private\_elb\_subnet\_ids) | n/a |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | n/a |
| <a name="output_private_subnet_sec_ids"></a> [private\_subnet\_sec\_ids](#output\_private\_subnet\_sec\_ids) | n/a |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | n/a |
| <a name="output_vpc_endpoint_secgrp"></a> [vpc\_endpoint\_secgrp](#output\_vpc\_endpoint\_secgrp) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->