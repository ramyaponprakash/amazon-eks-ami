cluster_name = "adex-prd-solace-eks-cluster"
vpc_name     = "adex-prd-solace"

eks_customer_cmk_key_arn = "arn:aws:kms:ap-southeast-1:704140326871:key/544321c8-ceb8-4edd-9c47-d6a813715acf"
eks_admin_role_arns = [
  "arn:aws:iam::704140326871:role/u-admin",
  "arn:aws:iam::704140326871:role/u-eksadmin",
  "arn:aws:iam::704140326871:role/u-ec2read"
]

// TODO: remove this after demo
//eks_cluster_endpoint_public = true

eks_network = {
  enable = true
}
vpc_cidr                      = "100.112.110.0/24"
vpc_nat_gw_eip_allocation_ids = ["eipalloc-0b598904c389de794"]
vpc_private_subnets = [
  {
    cidr       = "100.112.110.64/27"
    enable_elb = 1
  },
  {
    cidr       = "100.112.110.96/27"
    enable_elb = 1
  },
  {
    cidr       = "100.112.110.48/28"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]
vpc_public_subnets = [
  {
    cidr       = "100.112.110.0/28"
    enable_elb = 1
  },
  {
    cidr       = "100.112.110.16/28"
    enable_elb = 1
  },
  {
    cidr       = "100.112.110.32/28"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]
vpc_private_elb_subnets = [
  {
    cidr       = "100.112.110.128/28"
    enable_elb = 1
  },
  {
    cidr       = "100.112.110.144/28"
    enable_elb = 1
  },
  {
    cidr       = "100.112.110.160/28"
    enable_elb = 1
  }
]

bastion = {
  enable              = true
  vpc_id              = ""
  subnet_ids          = []
  iam_role            = "u-ec2read"
  ssh_cidr_blocks     = []
  ssh_prefix_list_ids = ["pl-04d17737125dbdb0f"]
}
