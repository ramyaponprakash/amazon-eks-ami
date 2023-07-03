# This will create the IAM Role for the kube-system:cluster-autoscaler service account
module "cluster-autoscaler_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.2.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-cluster-autoscaler"
  provider_url                  = replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.autoscaling.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cluster-autoscaler"]
}

// https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
// https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#full-cluster-autoscaler-features-policy-recommended
resource "aws_iam_policy" "autoscaling" {
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:DescribeImages",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "autoscaling:DescribeTags",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["arn:aws:autoscaling:ap-southeast-1:${var.account_id}:autoScalingGroup:*:autoScalingGroupName/*"],
      "Condition": {
        "StringLike": {
          "autoscaling:ResourceTag/eks:cluster-name": "${var.cluster_name}"
        }
      }
    }
  ]
}
POLICY
}
