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
  { from : "173.1.0.0/19", port : "443", description : "QA CIDR 1" },
  { from : "173.2.0.0/19", port : "443", description : "QA CIDR 2" },
  { from : "172.9.0.0/24", port : "443", description : "VPC self" },
]
eks_worker_node_access_cidrs = [
  { cidrs : ["0.0.0.0/0"], from_port : 8883, to_port : 8883, description : "MQTTS" },
  { cidrs : ["0.0.0.0/0"], from_port : 5671, to_port : 5671, description : "AMQPS" },
  { cidrs : ["0.0.0.0/0"], from_port : 15675, to_port : 15675, description : "WS MQTT" }, # kept previous port
  { cidrs : ["0.0.0.0/0"], from_port : 55443, to_port : 55443, description : "SMFS" },
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
  # https://docs.solace.com/Cloud/Deployment-Considerations/connectivity-model-k8s.htm
  tgw = [
    {
      destination : "13.236.32.115/32",
      target : "tgw-0b0fdbd326689589d" // TODO
    },
    {
      destination : "3.106.10.188/32", // TODO
      target : "tgw-0b0fdbd326689589d"
    },
    {
      destination : "3.105.186.75/32", // TODO
      target : "tgw-0b0fdbd326689589d"
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

vpc_cidr_pri = "172.9.0.0/24"
#vpc_cidr_sec = ""
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
  enable        = true
  public_access = false
  vpc_id        = ""
  subnet_ids    = []
  instance_type = "t2.micro"
  iam_role      = "u-ec2read"
  ami_id        = "ami-0aaee588abf059b37"
  http_proxy    = "http://squid.adex-qa.com:3128"
  https_proxy   = "http://squid.adex-qa.com:3128"
  no_proxy      = "localhost,127.0.0.1,169.254.169.254,172.9.0.0/24,.local,.svc,.eks.amazonaws.com"
}

bastion_secgrp_ingress_secgrp      = ["sg-0e35335b81ce6a8d7"]
bastion_secgrp_ingress_prefix_list = []

/*
bastion_secgrp_ingress_cidr = [
  {
    cidrs       = ["173.2.0.0/19", "173.1.0.0/19"]
    from_port   = 22
    to_port     = 22
    description = "from qa vpc"
  },
]*/
