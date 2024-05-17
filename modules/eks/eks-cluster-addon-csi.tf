resource "aws_eks_addon" "csi_driver" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/${var.cluster_name}-csi"

  depends_on = [
    module.aws-csi_assumable_role_admin,
    aws_iam_policy.aws-policy-csi,
    aws_eks_node_group.default_nodegroup
  ]
}

# This will create the IAM Role for the kube-system:ebs-csi-controller-sa service account
module "aws-csi_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.2.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-csi"
  provider_url                  = replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws-policy-csi.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_iam_policy" "aws-policy-csi" {
  name        = "aws-policy-csi-${var.cluster_name}"
  description = "IAM policy with permissions for the AWS CSI Driver"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalArn": "arn:aws:iam::${var.account_id}:role/${var.cluster_name}-csi"
          }
        }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:ModifyVolume"
      ],
      "Resource": [
        "arn:aws:ec2:ap-southeast-1:${var.account_id}:volume/*",
        "arn:aws:ec2:ap-southeast-1:${var.account_id}:instance/*"
      ],
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags"
      ],
      "Resource": [
        "arn:aws:ec2:ap-southeast-1:${var.account_id}:volume/*",
        "arn:aws:ec2:ap-southeast-1:${var.account_id}:snapshot/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": [
            "CreateVolume",
            "CreateSnapshot"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags"
      ],
      "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:snapshot/*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/Name": "adex-sol-eks-node-*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags"
      ],
      "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:volume/*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/eks:cluster-name": "${var.cluster_name}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags"
      ],
      "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:volume/*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume"
      ],
      "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:volume/*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteVolume"
      ],
      "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:volume/*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/KubernetesCluster": "${var.cluster_name}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteVolume"
      ],
      "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:volume/*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot"
      ],
      "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:snapshot/*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteSnapshot"
      ],
      "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:snapshot/*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteSnapshot"
      ],
      "Resource": "arn:aws:ec2:ap-southeast-1:${var.account_id}:snapshot/*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/eks:cluster-name": "${var.cluster_name}"
        }
      }
    }
  ]
}
POLICY
}
