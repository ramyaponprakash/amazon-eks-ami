account_id   = 342446142760
cluster_name = "adex-dev-solace-eks-cluster"
vpc_name     = "adex-dev-solace"

eks_customer_cmk_key_arn = "arn:aws:kms:ap-southeast-1:342446142760:key/c706f705-9a56-44f7-9db8-47364dfa93a6"
eks_admin_role_arns = [
  "arn:aws:iam::342446142760:role/admin-role",
  "arn:aws:iam::342446142760:role/ec2-eks-role",
  "arn:aws:iam::342446142760:role/u-ec2read"
]

eks_http_proxy              = ""
eks_cluster_endpoint_public = true

eks_api_endpoint_access_cidrs = [
  { from : "172.10.0.0/16", port : "443", description : "self CIDR" },
]
eks_worker_node_access_cidrs = []
eks_worker_node_access_prefix = [
  { prefix_list_ids : ["pl-0af10fe06357d6aff"], from_port : 0, to_port : 65535, description : "For ADEX team development convenience, sense-whitelist" },
]

network = {
  enable     = true
  create_vpc = true
  peers = [
    {
      destination : "173.3.0.0/19", // SOL-QA cidr
      target : "pcx-0f938cc9e044556b0"
    },
    {
      destination : "172.31.0.0/16", // DEV cidr
      target : "pcx-0a68cef3b16699a85"
    },
    {
      destination : "172.32.0.0/16", // DEV cidr
      target : "pcx-0a68cef3b16699a85"
    },
  ]
  # https://docs.solace.com/Cloud/Deployment-Considerations/connectivity-model-k8s.htm
  tgw = []
}

vpc_enable_private         = false
vpc_endpoint_allowed_cidrs = ["172.10.0.0/16"]

vpc_eip = {
  enable_eip = true
  count      = 1
}

vpc_nat_gateway = {
  enable                        = true
  vpc_nat_gw_eip_allocation_ids = []
}
vpc_nat_gw_ids = []

vpc_igw = {
  enable_igw = true
  count      = 1
}
vpc_igw_ids = []

vpc_cidr_pri = "172.10.0.0/16"
vpc_cidr_sec = ""

vpc_private_subnets = [
  {
    cidr       = "172.10.1.0/24"
    enable_elb = 1
  },
  {
    cidr       = "172.10.2.0/24"
    enable_elb = 1
  },
  {
    cidr       = "172.10.3.0/24"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  },
]

vpc_sec_enable_cidr     = false
vpc_sec_subnet_ids      = []
vpc_private_sec_subnets = []

vpc_public_subnets = [
  {
    cidr       = "172.10.4.0/24"
    enable_elb = 1
  },
  {
    cidr       = "172.10.5.0/24"
    enable_elb = 1
  },
  {
    cidr       = "172.10.6.0/24"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  },
]
vpc_private_elb_subnets = []

bastion = {
  enable        = true
  public_access = true
  vpc_id        = ""
  subnet_ids    = []
  ami_id        = "ami-02c4c96e0a37b397f"
  instance_type = "t2.micro"
  iam_role      = "u-ec2read"
  http_proxy    = ""
  https_proxy   = ""
  no_proxy      = ""
}

bastion_secgrp_ingress_cidr = [
  {
    cidrs       = ["172.10.0.0/16"]
    from_port   = 22
    to_port     = 22
    description = "from own vpc"
  },
]
bastion_secgrp_ingress_prefix_list = [
  {
    prefix_list_ids = ["pl-0af10fe06357d6aff"]
    from_port       = 22
    to_port         = 22
    description     = "sense-whitelist"
  },
]
bastion_secgrp_ingress_secgrp = []
