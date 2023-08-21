data "aws_iam_role" "bastion_ec2_role" {
  name = aws_iam_role.bastion_ec2_role.name
}

resource "aws_iam_instance_profile" "bastion_ec2_role" {
  name = aws_iam_role.bastion_ec2_role.name
  role = aws_iam_role.bastion_ec2_role.name
}

resource "aws_iam_role" "bastion_ec2_role" {
  name_prefix = "eks-bastion-role-"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                  "arn:aws:iam::${var.account_id}:root",
                  "arn:aws:iam::${var.account_id}:user/eks",
                  "arn:aws:iam::${var.account_id}:role/sgts.gitlab-dedicated"
                ],
                "Service": [
                    "ec2.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY

  tags = {
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_policy" "bastion_policy" {
  name_prefix = "bastion_policy_"
  description = "Access policy to ${var.cluster_name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:eks:ap-southeast-1:${var.account_id}:cluster/${var.cluster_name}"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::aws-quicksetup-patchpolicy-*"
    }
  ]
}
POLICY

  tags = {
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "bastion_ec2_bastion_policy" {
  policy_arn = aws_iam_policy.bastion_policy.arn
  role       = aws_iam_role.bastion_ec2_role.name
}

// SSM
resource "aws_iam_role_policy_attachment" "bastion_ec2_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_ec2_role.name
}