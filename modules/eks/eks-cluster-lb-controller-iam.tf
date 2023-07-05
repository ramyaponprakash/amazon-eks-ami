// https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#using-metadata-server-version-2-imdsv2
// https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#network-configuration

# This will create the IAM Role for the kube-system:aws-load-balancer-controller service account
module "aws-lb-controller_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.2.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-aws-lb-controller"
  provider_url                  = replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws-lb-controller-policy-nlb-ip.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}

// https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#deployment-considerations
resource "aws_iam_policy" "aws-lb-controller-policy-nlb-ip" {
  name        = "aws-lb-policy-nlb-${var.cluster_name}"
  description = "IAM policy with permissions for the AWS Load Balancer Controller"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "arn:aws:iam::${var.account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:security-group/*",
            "Condition": {
                "StringLike": {
                  "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:security-group/*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": [
              "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:loadbalancer/*",
              "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:targetgroup/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:loadbalancer/app/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:ap-southeast-1:${var.account_id}:targetgroup/*/*",
            "Condition": {
                "StringLike": {
                  "aws:ResourceTag/elbv2.k8s.aws/cluster": "${var.cluster_name}"
                }
            }
        }
    ]
}
POLICY
}
