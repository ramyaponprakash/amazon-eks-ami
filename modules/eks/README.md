<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-csi_assumable_role_admin"></a> [aws-csi\_assumable\_role\_admin](#module\_aws-csi\_assumable\_role\_admin) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 4.2.0 |
| <a name="module_aws-lb-controller_assumable_role_admin"></a> [aws-lb-controller\_assumable\_role\_admin](#module\_aws-lb-controller\_assumable\_role\_admin) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 4.2.0 |
| <a name="module_cluster-autoscaler_assumable_role_admin"></a> [cluster-autoscaler\_assumable\_role\_admin](#module\_cluster-autoscaler\_assumable\_role\_admin) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 4.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.core_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.kube_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.default_nodegroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_policy.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.aws-lb-controller-policy-nlb-ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.aws-policy-csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.customer_cmk_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_cluster-node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_cluster-AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cluster-AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cluster-AmazonEKSClusterPolicy-CMK](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cluster-AmazonEKSServicePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cluster-AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cluster-AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_cluster-AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.default_nodegroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.eks_cluster-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.eks_cluster-node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.eks_cluster-cluster-ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_cluster-node-ingress-cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_cluster-node-ingress-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_cluster-node-ingress-lbc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_cluster-node-ingress-prefix-list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_cluster-node-ingress-self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [kubernetes_annotations.remove_default_storage_class](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_config_map.aws_auth_configmap](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.proxy_configmap](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_storage_class.gp2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [kubernetes_storage_class.gp3](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [null_resource.default_node_group_asg_tags](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_ami.latest-cis-optimized-ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_arn.default_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_autoscaling_group.default_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/autoscaling_group) | data source |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster.cluster_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_session_context.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_eks_additional_no_proxy"></a> [eks\_additional\_no\_proxy](#input\_eks\_additional\_no\_proxy) | must start with starting comma | `string` | `""` | no |
| <a name="input_eks_admin_role_arns"></a> [eks\_admin\_role\_arns](#input\_eks\_admin\_role\_arns) | n/a | `list(string)` | `[]` | no |
| <a name="input_eks_api_endpoint_access_cidrs"></a> [eks\_api\_endpoint\_access\_cidrs](#input\_eks\_api\_endpoint\_access\_cidrs) | n/a | <pre>list(object({<br>    from        = string<br>    port        = string<br>    description = string<br>  }))</pre> | `[]` | no |
| <a name="input_eks_cluster_endpoint_private"></a> [eks\_cluster\_endpoint\_private](#input\_eks\_cluster\_endpoint\_private) | n/a | `bool` | `true` | no |
| <a name="input_eks_cluster_endpoint_public"></a> [eks\_cluster\_endpoint\_public](#input\_eks\_cluster\_endpoint\_public) | n/a | `bool` | `false` | no |
| <a name="input_eks_customer_cmk_key_arn"></a> [eks\_customer\_cmk\_key\_arn](#input\_eks\_customer\_cmk\_key\_arn) | n/a | `string` | n/a | yes |
| <a name="input_eks_default_no_proxy"></a> [eks\_default\_no\_proxy](#input\_eks\_default\_no\_proxy) | n/a | `string` | `"localhost,127.0.0.1,169.254.169.254,.local,.internal,.eks.amazonaws.com,:8080/health"` | no |
| <a name="input_eks_http_proxy"></a> [eks\_http\_proxy](#input\_eks\_http\_proxy) | n/a | `string` | n/a | yes |
| <a name="input_eks_node_group_iam_role_arns"></a> [eks\_node\_group\_iam\_role\_arns](#input\_eks\_node\_group\_iam\_role\_arns) | n/a | `list(string)` | `[]` | no |
| <a name="input_eks_private_ep_no_proxy"></a> [eks\_private\_ep\_no\_proxy](#input\_eks\_private\_ep\_no\_proxy) | n/a | `string` | `"s3.amazonaws.com,.s3.ap-southeast-1.amazonaws.com,sts.ap-southeast-1.amazonaws.com,ec2.ap-southeast-1.amazonaws.com,.dkr.ecr.ap-southeast-1.amazonaws.com,api.ecr.ap-southeast-1.amazonaws.com,autoscaling.ap-southeast-1.amazonaws.com,logs.ap-southeast-1.amazonaws.com,eks.ap-southeast-1.amazonaws.com,elasticloadbalancing.ap-southeast-1.amazonaws.com,ssm.ap-southeast-1.amazonaws.com,ssmmessages.ap-southeast-1.amazonaws.com,ec2messages.ap-southeast-1.amazonaws.com,monitoring.ap-southeast-1.amazonaws.com"` | no |
| <a name="input_eks_private_subnet_ids"></a> [eks\_private\_subnet\_ids](#input\_eks\_private\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_eks_worker_node_access_cidrs"></a> [eks\_worker\_node\_access\_cidrs](#input\_eks\_worker\_node\_access\_cidrs) | Provide cidr based whitelist to envs require to be accessed from public via Firewall to internal NLB (e.g. Prods) | <pre>list(object({<br>    cidrs       = list(string)<br>    from_port   = number<br>    to_port     = number<br>    description = string<br>  }))</pre> | `[]` | no |
| <a name="input_eks_worker_node_access_prefix"></a> [eks\_worker\_node\_access\_prefix](#input\_eks\_worker\_node\_access\_prefix) | Provide prefix based whitelist to envs require to be accessed from public without Firewall (e.g. DEV/QA) | <pre>list(object({<br>    prefix_list_ids = list(string)<br>    from_port       = number<br>    to_port         = number<br>    description     = string<br>  }))</pre> | `[]` | no |
| <a name="input_k8s_master_version"></a> [k8s\_master\_version](#input\_k8s\_master\_version) | The kubernetes version to use. Only used a creation time, ignored once the cluster exists. But will be used by node group update | `string` | `"1.25"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"ap-southeast-1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_account_id"></a> [aws\_account\_id](#output\_aws\_account\_id) | n/a |
| <a name="output_aws_partition_name"></a> [aws\_partition\_name](#output\_aws\_partition\_name) | n/a |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_cluster_node_secgrp_id"></a> [cluster\_node\_secgrp\_id](#output\_cluster\_node\_secgrp\_id) | n/a |
| <a name="output_cluster_secgrp_ids"></a> [cluster\_secgrp\_ids](#output\_cluster\_secgrp\_ids) | n/a |
| <a name="output_eks_cluster_role_arn"></a> [eks\_cluster\_role\_arn](#output\_eks\_cluster\_role\_arn) | n/a |
| <a name="output_eks_cluster_role_name"></a> [eks\_cluster\_role\_name](#output\_eks\_cluster\_role\_name) | n/a |
| <a name="output_eks_node_role_arn"></a> [eks\_node\_role\_arn](#output\_eks\_node\_role\_arn) | n/a |
| <a name="output_eks_node_role_name"></a> [eks\_node\_role\_name](#output\_eks\_node\_role\_name) | n/a |
| <a name="output_k8s-endpoint"></a> [k8s-endpoint](#output\_k8s-endpoint) | n/a |
| <a name="output_k8s-version"></a> [k8s-version](#output\_k8s-version) | n/a |
| <a name="output_storage_class_gp2"></a> [storage\_class\_gp2](#output\_storage\_class\_gp2) | n/a |
| <a name="output_storage_class_gp3"></a> [storage\_class\_gp3](#output\_storage\_class\_gp3) | n/a |
<!-- END_TF_DOCS -->