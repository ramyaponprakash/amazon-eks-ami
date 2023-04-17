resource "aws_iam_policy" "customer_cmk_access_policy" {
  count = var.eks_customer_cmk_key_arn != "" ? 1 : 0

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "${var.eks_customer_cmk_key_arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "${var.eks_customer_cmk_key_arn}",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster-AmazonEKSClusterPolicy-CMK" {
  count      = var.eks_customer_cmk_key_arn != "" ? 1 : 0
  policy_arn = aws_iam_policy.customer_cmk_access_policy[0].arn
  role       = aws_iam_role.eks_cluster.name
}
