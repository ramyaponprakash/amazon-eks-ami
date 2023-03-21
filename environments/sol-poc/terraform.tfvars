cluster_name = "solace-poc-cluster"
vpc_name     = "solace-poc-env"

eks_customer_cmk_key_arn = "arn:aws:kms:ap-southeast-1:342446142760:key/c706f705-9a56-44f7-9db8-47364dfa93a6"
eks_admin_role_arns = [
  "arn:aws:iam::342446142760:role/admin-role",
  "arn:aws:iam::342446142760:role/ec2-eks-role",
  "arn:aws:iam::342446142760:role/u-ec2read"
]

// TODO: remove this after demo
eks_cluster_endpoint_public = true

eks_network = {
  enable = true
}
vpc_cidr                      = "172.8.0.0/24"
vpc_nat_gw_eip_allocation_ids = ["eipalloc-019b75060b41e3a68"]
vpc_private_subnets = [
  {
    cidr       = "172.8.0.0/26"
    enable_elb = 1
  },
  {
    cidr       = "172.8.0.64/26"
    enable_elb = 1
  },
  {
    cidr       = "172.8.0.128/28"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]
vpc_public_subnets = [
  {
    cidr       = "172.8.0.144/28"
    enable_elb = 1
  },
  {
    cidr       = "172.8.0.160/28"
    enable_elb = 1
  },
  {
    cidr       = "172.8.0.176/28"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]
vpc_private_elb_subnets = [
  {
    cidr       = "172.8.0.192/28"
    enable_elb = 1
  },
  {
    cidr       = "172.8.0.208/28"
    enable_elb = 1
  },
  {
    cidr       = "172.8.0.224/28"
    enable_elb = 1
  }
]

bastion = {
  enable              = true
  cluster_name        = "alex-test-cluster"
  vpc_id              = "vpc-09a58d6d"
  subnet_ids          = ["subnet-03603dbfb617e41c4"]
  iam_role            = "ec2-eks-role"
  ssh_cidr_blocks     = ["172.8.0.0/24"]
  ssh_prefix_list_ids = ["pl-0af10fe06357d6aff"]
}
