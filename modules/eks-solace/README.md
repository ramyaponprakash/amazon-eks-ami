<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_node_group.prod1k](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_launch_template.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_launch_template.prod1k](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [null_resource.monitoring-asg-tags](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.prod1k-asg-tags](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_arn.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_arn.prod1k](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_autoscaling_group.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/autoscaling_group) | data source |
| [aws_autoscaling_group.prod1k](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/autoscaling_group) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_ssm_parameter.optimized-ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_messaging_tags"></a> [asg\_messaging\_tags](#input\_asg\_messaging\_tags) | n/a | <pre>list(object({<br>    type  = string<br>    key   = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "key": "ephemeral-storage",<br>    "type": "resources",<br>    "value": "20G"<br>  }<br>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_eks_additional_no_proxy"></a> [eks\_additional\_no\_proxy](#input\_eks\_additional\_no\_proxy) | must start with starting comma | `string` | `""` | no |
| <a name="input_eks_http_proxy"></a> [eks\_http\_proxy](#input\_eks\_http\_proxy) | n/a | `string` | n/a | yes |
| <a name="input_eks_node_role_arn"></a> [eks\_node\_role\_arn](#input\_eks\_node\_role\_arn) | n/a | `string` | n/a | yes |
| <a name="input_eks_node_role_name"></a> [eks\_node\_role\_name](#input\_eks\_node\_role\_name) | n/a | `string` | n/a | yes |
| <a name="input_eks_private_ep_no_proxy"></a> [eks\_private\_ep\_no\_proxy](#input\_eks\_private\_ep\_no\_proxy) | n/a | `string` | `"s3.amazonaws.com,.s3.ap-southeast-1.amazonaws.com,sts.ap-southeast-1.amazonaws.com,ec2.ap-southeast-1.amazonaws.com,.dkr.ecr.ap-southeast-1.amazonaws.com,api.ecr.ap-southeast-1.amazonaws.com,autoscaling.ap-southeast-1.amazonaws.com,logs.ap-southeast-1.amazonaws.com,eks.ap-southeast-1.amazonaws.com,elasticloadbalancing.ap-southeast-1.amazonaws.com"` | no |
| <a name="input_eks_private_subnet_ids"></a> [eks\_private\_subnet\_ids](#input\_eks\_private\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_labels_taints_monitoring"></a> [labels\_taints\_monitoring](#input\_labels\_taints\_monitoring) | n/a | <pre>object({<br>    labels = map(string)<br>    taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>  })</pre> | <pre>{<br>  "labels": {<br>    "nodeType": "monitoring"<br>  },<br>  "taints": [<br>    {<br>      "effect": "NO_EXECUTE",<br>      "key": "nodeType",<br>      "value": "monitoring"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_labels_taints_prod100k"></a> [labels\_taints\_prod100k](#input\_labels\_taints\_prod100k) | n/a | <pre>object({<br>    labels = map(string)<br>    taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>  })</pre> | <pre>{<br>  "labels": {<br>    "nodeType": "messaging",<br>    "serviceClass": "prod100k"<br>  },<br>  "taints": [<br>    {<br>      "effect": "NO_EXECUTE",<br>      "key": "nodeType",<br>      "value": "messaging"<br>    },<br>    {<br>      "effect": "NO_EXECUTE",<br>      "key": "serviceClass",<br>      "value": "prod100k"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_labels_taints_prod10k"></a> [labels\_taints\_prod10k](#input\_labels\_taints\_prod10k) | n/a | <pre>object({<br>    labels = map(string)<br>    taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>  })</pre> | <pre>{<br>  "labels": {<br>    "nodeType": "messaging",<br>    "serviceClass": "prod10k"<br>  },<br>  "taints": [<br>    {<br>      "effect": "NO_EXECUTE",<br>      "key": "nodeType",<br>      "value": "messaging"<br>    },<br>    {<br>      "effect": "NO_EXECUTE",<br>      "key": "serviceClass",<br>      "value": "prod10k"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_labels_taints_prod1k"></a> [labels\_taints\_prod1k](#input\_labels\_taints\_prod1k) | n/a | <pre>object({<br>    labels = map(string)<br>    taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>  })</pre> | <pre>{<br>  "labels": {<br>    "nodeType": "messaging",<br>    "serviceClass": "prod1k"<br>  },<br>  "taints": [<br>    {<br>      "effect": "NO_EXECUTE",<br>      "key": "nodeType",<br>      "value": "messaging"<br>    },<br>    {<br>      "effect": "NO_EXECUTE",<br>      "key": "serviceClass",<br>      "value": "prod1k"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_node_groups_100k_instance_type"></a> [node\_groups\_100k\_instance\_type](#input\_node\_groups\_100k\_instance\_type) | n/a | `string` | `"r5.2xlarge"` | no |
| <a name="input_node_groups_10k_instance_type"></a> [node\_groups\_10k\_instance\_type](#input\_node\_groups\_10k\_instance\_type) | n/a | `string` | `"r5.xlarge"` | no |
| <a name="input_node_groups_1k_instance_type"></a> [node\_groups\_1k\_instance\_type](#input\_node\_groups\_1k\_instance\_type) | n/a | `string` | `"r5.large"` | no |
| <a name="input_node_groups_count_messaging"></a> [node\_groups\_count\_messaging](#input\_node\_groups\_count\_messaging) | The number of messaging node groups for each service class (one for each zone). | `number` | `2` | no |
| <a name="input_node_groups_monitoring_instance_type"></a> [node\_groups\_monitoring\_instance\_type](#input\_node\_groups\_monitoring\_instance\_type) | n/a | `string` | `"t3.medium"` | no |
| <a name="input_node_groups_settings_messaging"></a> [node\_groups\_settings\_messaging](#input\_node\_groups\_settings\_messaging) | n/a | <pre>object({<br>    desired_size = number<br>    min_size     = number<br>    max_size     = number<br>  })</pre> | <pre>{<br>  "desired_size": 0,<br>  "max_size": 50,<br>  "min_size": 0<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->