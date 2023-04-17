cluster_name = "adex-prd-solace-eks-cluster"
vpc_name     = "adex-prd-solace"

eks_customer_cmk_key_arn = "arn:aws:kms:ap-southeast-1:704140326871:key/544321c8-ceb8-4edd-9c47-d6a813715acf"
eks_admin_role_arns = [
  "arn:aws:iam::704140326871:role/u-admin",
  "arn:aws:iam::704140326871:role/u-eksadmin",
  "arn:aws:iam::704140326871:role/adex-eksadmin"
]

eks_http_proxy              = "http://squid-solx.adex.com:3128"
eks_cluster_endpoint_public = false
eks_api_endpoint_access_cidrs = [
  { from : "172.22.223.0/25", port : "443" }, // SDX_PRD 1
  { from : "172.16.110.0/24", port : "443" }  // SDX_PRD 2
]

network = {
  enable = true
  peers = [
    {
      destination : "172.22.223.0/25", // SDX_PRD cidr
      target : "pcx-0573794d0b2a23d7e"
    },
    {
      destination : "172.16.110.0/24", // SDX_PRD cidr
      target : "pcx-0573794d0b2a23d7e"
    },
    {
      destination : "10.189.118.0/25", // SOLI cidr
      target : "pcx-0183e747499457bef"
    }
  ]
}

vpc_enable_private         = true
vpc_endpoint_allowed_cidrs = ["100.112.110.0/24", "100.80.27.128/26"] // SOLX cidr (pri, sec)

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

vpc_cidr_pri = "100.112.110.0/24" // SOLX
vpc_cidr_sec = "100.80.27.128/26" // SOLX

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
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  },
  {
    cidr       = "100.112.110.192/26"
    enable_elb = 1
  }
]

vpc_sec_enable_cidr = false
# NOTE: will be used for NLB provision only, the cidr can not provision EC2
vpc_sec_subnet_ids = ["subnet-04ef45b8c54500dd2", "subnet-0b1a0b403d9f7219e"]

vpc_private_sec_subnets = []

vpc_public_subnets      = []
vpc_private_elb_subnets = []

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
  subnet_gw_ids  = []
  iam_role       = "ec2ssm"
  ami_squid      = "ami-0b6b2786d08d30845"
  zone_id        = "Z0608925I3JGEL99Z85J"
  record_name    = "squid-solx"
  squid_key_name = "adex-squid-solx"
  kms_key_id     = "arn:aws:kms:ap-southeast-1:704140326871:key/0e7a17d3-f755-49f4-958b-c8e3976f4d4f"
}

squid_secgrp_ingress_cidr = [
  {

    cidrs       = ["100.112.110.0/24", "100.80.27.128/26"]
    port        = 3128
    description = "from SOLX vpc"
  },
  {
    cidrs       = ["10.189.118.0/25"]
    port        = 3128
    description = "from peer vpc cidr (SOLI)"
  },
  {
    cidrs       = ["100.112.110.0/24", "100.80.27.128/26"]
    port        = 22
    description = "from SOLX vpc"
  },
]

squid_secgrp_ingress_secgrp = [
  {
    secgrp_ids  = ["sg-0dd3d667f43ec5703"]
    port        = 22
    description = "from mgmt"
  },
]

