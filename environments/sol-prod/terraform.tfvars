cluster_name = "adex-prd-solace-eks-cluster"
vpc_name     = "adex-prd-solace"

eks_customer_cmk_key_arn = "arn:aws:kms:ap-southeast-1:704140326871:key/544321c8-ceb8-4edd-9c47-d6a813715acf"
eks_admin_role_arns = [
  "arn:aws:iam::704140326871:role/u-admin",
  "arn:aws:iam::704140326871:role/u-eksadmin",
  "arn:aws:iam::704140326871:role/adex-eksadmin"
]

// TODO: remove this after demo
eks_cluster_endpoint_public = true

network = {
  enable = true
}

vpc_enable_private         = true
vpc_endpoint_allowed_cidrs = ["100.112.110.0/24"]

vpc_eip = {
  enable = false
}

vpc_nat_gateway = {
  enable                        = false
  vpc_nat_gw_eip_allocation_ids = ["eipalloc-034fbe49c22174c58", "eipalloc-0d47e96e0b789e780"]
}

vpc_igw = {
  enable = false
}

vpc_nat_gw_ids = ["nat-041c6ab43bae993d4", "nat-0c9658ee7bcaa76a5"]

vpc_igw_ids = ["igw-05de26569418b687e"]
//vpc_igw_ids = []

vpc_cidr_pri = "100.112.110.0/24"
vpc_cidr_sec = "100.80.27.128/26"

vpc_private_subnets = [
  {
    cidr       = "100.112.110.0/26"
    enable_elb = 1
  },
  {
    cidr       = "100.112.110.64/26"
    enable_elb = 1
  },
  {
    cidr       = "100.112.110.128/26"
    enable_elb = 1
  },
  {
    cidr       = "100.112.110.192/26"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]

vpc_sec_enable_cidr = false
vpc_sec_subnet_ids  = ["subnet-04ef45b8c54500dd2", "subnet-0b1a0b403d9f7219e"]

vpc_private_sec_subnets = [
  {
    cidr       = "100.80.27.128/28"
    enable_elb = 1
  },
  {
    cidr       = "100.80.27.144/28"
    enable_elb = 1
  },
  {
    cidr       = "100.80.27.160/27"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]

vpc_public_subnets = [
  /*{
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
  }*/
]
vpc_private_elb_subnets = [
  /*{
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
  }*/
]

bastion = {
  enable              = true
  public_access       = false
  vpc_id              = ""
  subnet_ids          = []
  iam_role            = "adex-eksadmin"
  ssh_cidr_blocks     = []
  ssh_prefix_list_ids = ["pl-04d17737125dbdb0f"]
}

squid = {
  vpc_id         = ""
  subnet_ids     = []
  iam_role       = "ec2ssm"
  ami_squid      = "ami-0b6b2786d08d30845"
  squid_key_name = "adex-squid-solx"
  kms_key_id     = "arn:aws:kms:ap-southeast-1:704140326871:key/0e7a17d3-f755-49f4-958b-c8e3976f4d4f"
}
