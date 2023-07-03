account_id   = 704140326871
cluster_name = "adex-int-solace-eks-cluster"
vpc_name     = "adex-intra-solace"
vpc_id       = "vpc-050a2b7cde1cb187e"

eks_customer_cmk_key_arn = "arn:aws:kms:ap-southeast-1:704140326871:key/544321c8-ceb8-4edd-9c47-d6a813715acf"
eks_admin_role_arns = [
  "arn:aws:iam::704140326871:role/u-admin",
  "arn:aws:iam::704140326871:role/u-eksadmin",
  "arn:aws:iam::704140326871:role/adex-eksadmin"
]

eks_http_proxy              = "http://squid-intra.adex.com:3128"
eks_cluster_endpoint_public = false
eks_api_endpoint_access_cidrs = [
  { from : "172.22.223.0/25", port : "443", description : "SDX_PRD CIDR 1" }, //will be removed after ci/cd setup has been done
  { from : "172.16.110.0/24", port : "443", description : "SDX_PRD CIDR 2" }, //will be removed after ci/cd setup has been done
  { from : "10.193.135.0/24", port : "443", description : "SDX_INTRA CIDR 1" },
  { from : "10.196.142.0/25", port : "443", description : "SDX_INTRA CIDR 2" },
  { from : "172.16.109.0/24", port : "443", description : "SDX_MGMT CIDR 1" },
  { from : "172.22.222.128/25", port : "443", description : "SDX_MGMT CIDR 2" },
  { from : "10.189.118.0/25", port : "443", description : "Self CIDR 1" },
  { from : "100.80.29.192/26", port : "443", description : "Self CIDR 2" },
]

network = {
  enable = true
  peers = [
    {
      destination : "10.193.135.0/24", // SDX_INTRA cidr
      target : "pcx-057c120394a4dfe70"
    },
    {
      destination : "10.196.142.0/25", // SDX_INTRA cidr
      target : "pcx-057c120394a4dfe70"
    },
    {
      destination : "100.112.110.0/24", // SOLX cidr
      target : "pcx-0183e747499457bef"
    },
    {
      destination : "172.16.109.0/24", // MGMT cidr
      target : "pcx-0376da7d85c03e667"
    }
  ]
  # https://docs.solace.com/Cloud/Deployment-Considerations/connectivity-model-k8s.htm
  tgw = [
    {
      destination : "13.236.32.115/32",
      target : "tgw-0c173b5b87a3ad575" // adex-solace
    },
    {
      destination : "3.106.10.188/32",
      target : "tgw-0c173b5b87a3ad575" // adex-solace
    },
    {
      destination : "3.105.186.75/32",
      target : "tgw-0c173b5b87a3ad575" // adex-solace
    }
  ]
}

vpc_enable_private         = true
vpc_endpoint_allowed_cidrs = ["10.189.118.0/25", "100.80.29.192/26"] // SOLI cidr (pri, sec)

vpc_eip = {
  enable = false
}

vpc_nat_gateway = {
  enable                        = false
  vpc_nat_gw_eip_allocation_ids = []
  # vpc_nat_gw_eip_allocation_ids = ["eipalloc-034fbe49c22174c58", "eipalloc-0d47e96e0b789e780"]
}

vpc_igw = {
  enable = false
}

#vpc_nat_gw_ids = ["nat-041c6ab43bae993d4", "nat-0c9658ee7bcaa76a5"]
vpc_nat_gw_ids = []

#vpc_igw_ids = ["igw-05de26569418b687e"]
vpc_igw_ids = []

vpc_cidr_pri = "10.189.118.0/25"  // SOLI
vpc_cidr_sec = "100.80.29.192/26" // SOLI

vpc_private_subnets = [
  {
    cidr       = "10.189.118.0/26"
    enable_elb = 1
  },
  {
    cidr       = "10.189.118.64/27"
    enable_elb = 1
  },
  {
    cidr       = "10.189.118.96/27"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]

vpc_sec_enable_cidr = false
# NOTE: will be used for NLB provision only, the cidr can not provision EC2
vpc_sec_subnet_ids = ["subnet-0ef1eea60adbf4055", "subnet-05c8a0fec649e433d"]

vpc_private_sec_subnets = []

vpc_public_subnets      = []
vpc_private_elb_subnets = []

bastion = {
  enable        = true
  public_access = false
  vpc_id        = ""
  subnet_ids    = []
  iam_role      = "adex-eksadmin"
  ami_id        = "ami-0aaee588abf059b37"
  http_proxy    = "http://squid-intra.adex.com:3128"
  https_proxy   = "http://squid-intra.adex.com:3128"
  no_proxy      = "localhost,127.0.0.1,169.254.169.254,.eks.amazonaws.com"
}

bastion_secgrp_ingress_cidr = [
  #  {
  #    cidrs       = ["10.189.118.0/25", "100.80.29.192/26"]
  #    from_port   = 22
  #    to_port     = 22
  #    description = "from SOLI vpc"
  #  },
]

bastion_secgrp_ingress_prefix_list = []

bastion_secgrp_ingress_secgrp = [
  {
    secgrp_id   = "sg-0a50de674c5138209"
    from_port   = 22
    to_port     = 22
    description = "from SDX_INTRA"
  },
]
