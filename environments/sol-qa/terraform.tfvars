account_id   = 342446142760
cluster_name = "adex-qa-solace-eks-cluster"
vpc_name     = "adex-qa-solace"

eks_customer_cmk_key_arn = "arn:aws:kms:ap-southeast-1:342446142760:key/c706f705-9a56-44f7-9db8-47364dfa93a6"
eks_admin_role_arns = [
  "arn:aws:iam::342446142760:role/sgts.gitlab-dedicated",
  "arn:aws:iam::342446142760:role/AWSReservedSSO_agency_admin_df42a4dd8d917651"
]
eks_http_proxy              = ""
eks_cluster_endpoint_public = false

eks_api_endpoint_access_cidrs = [
  { from : "173.1.0.0/19", port : "443", description : "QA CIDR 1" },
  { from : "173.2.0.0/19", port : "443", description : "QA CIDR 2" },
  { from : "173.3.0.0/19", port : "443", description : "VPC self" },
]

eks_cluster_egress_access_cidrs = [
  { from : "173.3.0.0/19", port : "4443", description : "Self CIDR 1" },
  { from : "173.3.0.0/19", port : "9443", description : "Self CIDR 1" },
]

eks_worker_node_access_cidrs = []
eks_worker_node_access_prefix = [
  { prefix_list_ids : ["pl-0af10fe06357d6aff"], from_port : 0, to_port : 65535, description : "For ADEX team development convenience, sense-whitelist" },
]

eks_worker_node_egress_access_cidrs = [
  { from : "173.3.0.0/19", port : "10250", description : "Self CIDR 1" },
  { from : "0.0.0.0/0", port : "443", description : "for OS updates" },
  { from : "173.3.0.0/19", port : "514", description : "Self CIDR 1" },
  { from : "172.10.0.0/16", port : "55443", description : "to dev bridge" },
  { from : "3.106.10.188/32", port : "55443", description : "for Solace MCA" },
  { from : "173.3.0.0/19", port : "55443", description : "Self CIDR 1" },
  { from : "3.105.186.75/32", port : "55443", description : "for Solace MCA" },
  { from : "13.236.32.115/32", port : "55443", description : "for Solace MCA" },
  { from : "173.3.0.0/19", port : "5550", description : "Self CIDR 1" },
  { from : "173.3.0.0/19", port : "55555", description : "Self CIDR 1" },
  { from : "0.0.0.0/0", port : "80", description : "for OS updates" },
  { from : "173.3.0.0/19", port : "8741", description : "Self CIDR 1" },
]

eks_worker_node_egress_tcp_HA = [
  { from : "173.3.0.0/19", port : "8300", to : "8302", description : "Self CIDR 1" },
]

eks_worker_node_egress_udp_HA = [
  { from : "173.3.0.0/19", port : "8301", to : "8302", description : "Self CIDR 1" },
]

eks_worker_node_egress_tcp_dns = [
  { from : "173.3.0.0/19", port : "53", description : "Self CIDR 1" },
]

eks_worker_node_egress_udp_dns = [
  { from : "173.3.0.0/19", port : "53", description : "Self CIDR 1" },
]

network = {
  enable     = true
  create_vpc = true
  peers = [
    {
      destination : "173.1.0.0/19",
      target : "pcx-05e8ef9768c8ae0a2"
    },
    {
      destination : "173.2.0.0/19",
      target : "pcx-05e8ef9768c8ae0a2"
    },
    {
      destination : "172.10.0.0/16",
      target : "pcx-0f938cc9e044556b0"
    },
  ]
  # https://docs.solace.com/Cloud/Deployment-Considerations/connectivity-model-k8s.htm
  tgw = []
}

vpc_enable_private         = false
vpc_endpoint_allowed_cidrs = ["173.3.0.0/19"]

# QA solace vpc will reach internet using own igw
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

vpc_cidr_pri = "173.3.0.0/19"
#vpc_cidr_sec = ""
vpc_private_subnets = [
  {
    cidr       = "173.3.0.0/26"
    enable_elb = 1
  },
  {
    cidr       = "173.3.0.64/26"
    enable_elb = 1
  },
  {
    cidr       = "173.3.0.192/26"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]
vpc_public_subnets = [
  {
    cidr       = "173.3.1.0/26"
    enable_elb = 1
  },
  {
    cidr       = "173.3.1.64/26"
    enable_elb = 1
  },
  {
    cidr       = "173.3.1.192/26"
    enable_elb = 0 // Don't attach the ELB to the monitor AZ
  }
]
vpc_private_elb_subnets = []
vpc_private_sec_subnets = []
vpc_sec_enable_cidr     = false
vpc_sec_subnet_ids      = []
gcc_vpc_tags = {
  "Type"                              = "Empty"
  "ec2:ResourceTag/gcc:security:zone" = "migrated-Empty-compartment"
  "gcc:origin"                        = "v1"
  "gcc:team"                          = "Agency"
  "type"                              = "Empty"
}

bastion = {
  enable        = true
  public_access = false
  vpc_id        = ""
  subnet_ids    = []
  instance_type = "t2.micro"
  ami_id        = "ami-05ad04538563a11ac" # 148623356839/GT_GCCS_StandardBuild_AML_2_on_2023-08-17_07.35.38
  http_proxy    = ""
  https_proxy   = ""
  no_proxy      = ""
}

bastion_secgrp_ingress_secgrp      = []
bastion_secgrp_ingress_prefix_list = []
bastion_secgrp_ingress_cidr        = []
