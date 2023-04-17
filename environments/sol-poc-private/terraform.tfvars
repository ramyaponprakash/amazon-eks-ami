cluster_name = "adex-poc-private-cluster"
vpc_name     = "adex-poc-private"

eks_customer_cmk_key_arn = "arn:aws:kms:ap-southeast-1:342446142760:key/c706f705-9a56-44f7-9db8-47364dfa93a6"
eks_admin_role_arns = [
  "arn:aws:iam::342446142760:role/admin-role",
  "arn:aws:iam::342446142760:role/ec2-eks-role",
  "arn:aws:iam::342446142760:role/u-ec2read"
]
eks_http_proxy              = "http://squid.adex-qa.com:3128"
eks_cluster_endpoint_public = false
eks_api_endpoint_access_cidrs = [
  { from : "173.1.0.0/19", port : "443" },
  { from : "173.2.0.0/19", port : "443" }
]

network = {
  enable     = true
  create_vpc = true
  peers = [
    {
      destination : "173.1.0.0/19",
      target : "pcx-00713693324ba3178"
    },
    {
      destination : "173.2.0.0/19",
      target : "pcx-00713693324ba3178"
    }
  ]
}

vpc_enable_private         = true
vpc_endpoint_allowed_cidrs = ["172.9.0.0/24"]

vpc_eip = {
  enable = false
}

vpc_nat_gateway = {
  enable                        = false
  vpc_nat_gw_eip_allocation_ids = []
}

vpc_igw = {
  enable = false
}

vpc_nat_gw_ids = []

vpc_igw_ids = []

vpc_cidr = "172.9.0.0/24"
vpc_private_subnets = [
  {
    cidr       = "172.9.0.0/26"
    enable_elb = 1
  },
  {
    cidr       = "172.9.0.64/26"
    enable_elb = 1
  },
  {
    cidr       = "172.9.0.192/26"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]
vpc_public_subnets      = []
vpc_private_elb_subnets = []
vpc_private_sec_subnets = []
vpc_sec_enable_cidr     = false
vpc_sec_subnet_ids      = []

bastion = {
  enable              = true
  public_access       = false
  vpc_id              = ""
  subnet_ids          = []
  instance_type       = "t2.micro"
  iam_role            = "u-ec2read"
  ssh_cidr_blocks     = ["173.1.0.0/19", "173.2.0.0/19"]
  ssh_prefix_list_ids = ["pl-0af10fe06357d6aff"]
}
