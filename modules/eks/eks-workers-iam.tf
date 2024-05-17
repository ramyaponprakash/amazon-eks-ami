// https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html

resource "aws_iam_role" "eks_cluster-node" {
  name = "${var.cluster_name}-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.${data.aws_partition.this.dns_suffix}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

/*resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_cluster-node.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster-node.name
}

// IPv4
resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster-node.name
}

// SSM
resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_cluster-node.name
}*/


resource "aws_iam_policy" "EC2ContainerRegistryReadOnly" {
  name        = "ec2containerregistryreadOnly-${var.cluster_name}"
  description = "IAM policy with permissions for the ecr"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalArn": "arn:aws:iam::${var.account_id}:role/${var.cluster_name}-node"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_policy" "EKS_CNI_Policy" {
  name        = "eks-cni-policy-${var.cluster_name}"
  description = "IAM policy with permissions for the eks cni"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AmazonEKSCNIPolicy",
            "Effect": "Allow",
            "Action": [
                "ec2:AssignPrivateIpAddresses",
                "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeSubnets",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalArn": "arn:aws:iam::${var.account_id}:role/${var.cluster_name}-node"
                }
            }
        },
        {
            "Sid": "AmazonEKSCNIPolicyENITag",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:network-interface/*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_policy" "EKSWorkerNodePolicy" {
  name        = "eksworkernodepolicy-${var.cluster_name}"
  description = "IAM policy with permissions for the eks worker node"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "WorkerNodePermissions",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVpcs",
                "eks:DescribeCluster",
                "eks-auth:AssumeRoleForPodIdentity",
                "eks:DescribeNodegroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalArn": "arn:aws:iam::${var.account_id}:role/${var.cluster_name}-node"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_policy" "SSMManagedInstanceCore" {
  name        = "ssmmanagedinstancecore-${var.cluster_name}"
  description = "IAM policy with permissions for the ssm"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:DescribeDocument",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:PutInventory",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*",
            "Condition": {
                "ArnLike": {
                    "aws:PrincipalArn": "arn:aws:iam::${var.account_id}:role/*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ec2:SourceInstanceARN": "arn:aws:ec2:ap-southeast-1:${var.account_id}:instance/*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ec2:SourceInstanceARN": "arn:aws:ec2:ap-southeast-1:${var.account_id}:instance/*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::aws-quicksetup-patchpolicy-*"
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "eks_cluster-EC2ContainerRegistryReadOnly" {
  policy_arn = aws_iam_policy.EC2ContainerRegistryReadOnly.arn
  role       = aws_iam_role.eks_cluster-node.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster-EKS_CNI_Policy" {
  policy_arn = aws_iam_policy.EKS_CNI_Policy.arn
  role       = aws_iam_role.eks_cluster-node.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster-EKSWorkerNodePolicy" {
  policy_arn = aws_iam_policy.EKSWorkerNodePolicy.arn
  role       = aws_iam_role.eks_cluster-node.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster-SSMManagedInstanceCore" {
  policy_arn = aws_iam_policy.SSMManagedInstanceCore.arn
  role       = aws_iam_role.eks_cluster-node.name
}