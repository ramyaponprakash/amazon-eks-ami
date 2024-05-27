account_id   = 704140326871
cluster_name = "adex-prd-solace-eks-cluster"
vpc_name     = "adex-prd-solace"
vpc_id       = "vpc-0f40f6277c878bbab"

eks_customer_cmk_key_arn = "arn:aws:kms:ap-southeast-1:704140326871:key/544321c8-ceb8-4edd-9c47-d6a813715acf"
eks_admin_role_arns = [
  "arn:aws:iam::704140326871:role/sgts.gitlab-dedicated",
  "arn:aws:iam::704140326871:role/AWSReservedSSO_agency_admin_63459625b2e64cf1"
]

eks_http_proxy              = "http://squid-solx.adex.com:3128"
eks_cluster_endpoint_public = false
eks_api_endpoint_access_cidrs = [
  { from : "172.22.223.0/25", port : "443", description : "SDX_PRD CIDR 1" },
  { from : "172.16.110.0/24", port : "443", description : "SDX_PRD CIDR 2" },
  { from : "100.112.110.0/24", port : "443", description : "Self CIDR 1" },
  { from : "100.80.27.128/26", port : "443", description : "Self CIDR 2" },
  { from : "172.16.109.0/28", port : "443", description : "prod bridge subnet for deploy" },
  { from : "100.112.110.0/24", port : "943", description : "for mca" },
]

eks_cluster_egress_access_cidrs = [
  { from : "100.112.110.0/24", port : "4443", description : "Self CIDR 1" },
  { from : "100.112.110.0/24", port : "9443", description : "Self CIDR 1" },
]

eks_worker_node_egress_access_cidrs = [
  { from : "100.112.110.0/24", port : "10250", description : "Self CIDR 1" },
  { from : "100.80.27.0/24", port : "3128", description : "for squid" },
  { from : "0.0.0.0/0", port : "443", description : "for OS updates" },
  { from : "100.112.110.0/24", port : "443", description : "Self CIDR 1" },
  { from : "172.16.109.128/28", port : "50514", description : "for logstash-server" },
  { from : "100.112.110.0/24", port : "514", description : "Self CIDR 1" },
  { from : "10.189.118.0/24", port : "55443", description : "to SOLI bridge" },
  { from : "3.106.10.188/32", port : "55443", description : "for Solace MCA" },
  { from : "100.112.110.0/24", port : "55443", description : "Self CIDR 1" },
  { from : "3.105.186.75/32", port : "55443", description : "for Solace MCA" },
  { from : "13.236.32.115/32", port : "55443", description : "for Solace MCA" },
  { from : "100.112.110.0/24", port : "5550", description : "Self CIDR 1" },
  { from : "100.112.110.0/24", port : "55555", description : "Self CIDR 1" },
  { from : "0.0.0.0/0", port : "80", description : "for OS updates" },
  { from : "100.112.110.0/24", port : "8741", description : "Self CIDR 1" },
]

eks_worker_node_egress_tcp_HA = [
  { from : "100.112.110.0/24", port : "8300", to : "8302", description : "Self CIDR 1" },
]

eks_worker_node_egress_udp_HA = [
  { from : "100.112.110.0/24", port : "8301", to : "8302", description : "Self CIDR 1" },
]

eks_worker_node_egress_tcp_dns = [
  { from : "100.112.110.0/24", port : "53", description : "Self CIDR 1" },
]

eks_worker_node_egress_udp_dns = [
  { from : "100.112.110.0/24", port : "53", description : "Self CIDR 1" },
]

network = {
  enable = true
  peers = [
    {
      destination : "172.22.223.0/25", // SDX_PRD cidr
      target : "pcx-0573794d0b2a23d7e"
    },
    {
      destination : "172.16.109.0/24", // SDX_PRD cidr
      target : "pcx-00c00bb36f5ede8d7"
    },
    {
      destination : "172.16.110.0/24", // SDX_PRD cidr
      target : "pcx-0573794d0b2a23d7e"
    },
    {
      destination : "10.189.118.0/25", // SOLI cidr
      target : "pcx-0183e747499457bef"
    },
    {
      destination : "172.16.108.0/24", // NIPS cidr
      target : "pcx-046a96fb0342406c7"
    },
    {
      destination : "172.22.227.0/24", // NIPS cidr
      target : "pcx-046a96fb0342406c7"
    },
    {
      destination : "172.23.78.0/24", // NIPS cidr
      target : "pcx-046a96fb0342406c7"
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
vpc_endpoint_allowed_cidrs = ["100.112.110.0/24", "100.80.27.128/26"] // SOLX cidr (pri, sec)

vpc_eip = {
  enable_eip = false
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
  enable        = true
  public_access = false
  vpc_id        = ""
  subnet_ids    = []
  ami_id        = "ami-05ad04538563a11ac" # 148623356839/GT_GCCS_StandardBuild_AML_2_on_2023-08-17_07.35.38
  http_proxy    = "http://squid-solx.adex.com:3128"
  https_proxy   = "http://squid-solx.adex.com:3128"
  no_proxy      = "localhost,127.0.0.1,169.254.169.254,.eks.amazonaws.com"
}

bastion_secgrp_ingress_cidr        = []
bastion_secgrp_ingress_prefix_list = []
bastion_secgrp_ingress_secgrp      = []

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
    from_port   = 3128
    to_port     = 3128
    description = "from SOLX vpc"
  },
  {
    cidrs       = ["10.189.118.0/25"]
    from_port   = 3128
    to_port     = 3128
    description = "from peer vpc cidr (SOLI)"
  },
  {
    cidrs       = ["100.112.110.0/24", "100.80.27.128/26"]
    from_port   = 22
    to_port     = 22
    description = "from SOLX vpc"
  },
]

squid_secgrp_ingress_secgrp = [
  {
    secgrp_id   = "sg-0dd3d667f43ec5703"
    from_port   = 22
    to_port     = 22
    description = "from mgmt"
  },
]

