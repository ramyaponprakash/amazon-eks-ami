variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "cluster_name" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "vpc_cidr_pri" {
  type = string
}

variable "vpc_cidr_sec" {
  type    = string
  default = ""
}

variable "eks_customer_cmk_key_arn" {
  type    = string
  default = ""
}

variable "eks_private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "eks_admin_role_arns" {
  type    = list(string)
  default = []
}

variable "eks_cluster_endpoint_public" {
  type    = bool
  default = false
}

variable "network" {
  type = object({
    enable     = optional(bool, false)
    create_vpc = optional(bool, false)
    peers = list(object({
      destination = string
      target      = string
    }))
    tgw = list(object({
      destination = string
      target      = string
    }))
  })
}

variable "vpc_eip" {
  type = object({
    enable = optional(bool, false)
    count  = optional(number, 1)
  })
}

variable "vpc_endpoint_allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "vpc_endpoint_subnets" {
  type    = list(string)
  default = []
}

variable "vpc_sec_enable_cidr" {
  type    = bool
  default = false
}

variable "vpc_sec_subnet_ids" {
  type    = list(string)
  default = []
}

variable "vpc_private_sec_subnets" {
  type = list(object({
    cidr       = string
    enable_elb = number
  }))
  default = []
}


variable "vpc_enable_private" {
  type    = bool
  default = false
}


variable "vpc_nat_gateway" {
  type = object({
    enable                        = optional(bool, false)
    vpc_nat_gw_eip_allocation_ids = optional(list(string))
  })
}


variable "vpc_igw" {
  type = object({
    enable = optional(bool, false)
    count  = optional(number, 0)
  })
}

variable "vpc_nat_gw_ids" {
  type    = list(string)
  default = []
}

variable "vpc_igw_ids" {
  type    = list(string)
  default = []
}

variable "vpc_nat_gw_eip_allocation_ids" {
  type    = list(string)
  default = []
}


variable "vpc_secondary_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "vpc_excluded_zone_names" {
  type    = list(string)
  default = []
}

variable "vpc_public_subnets" {
  type = list(object({
    cidr       = string
    enable_elb = number
  }))
  default = []
}

variable "vpc_private_subnets" {
  type = list(object({
    cidr       = string
    enable_elb = number
  }))
  default = []
}

variable "vpc_private_elb_subnets" {
  type = list(object({
    cidr       = string
    enable_elb = number
  }))
  default = []
}

variable "bastion" {
  type = object({
    enable               = optional(bool, true)
    instance_type        = optional(string, "t3.medium")
    public_access        = optional(bool, true)
    attach_eip           = optional(bool, false)
    subnet_ids           = list(string)
    generate_private_key = optional(bool, true)
    private_key_path     = optional(string, "empty")
    public_key_path      = optional(string, "empty")
    hosts_number         = optional(number, 1)
    iam_role             = string
    ssh_cidr_blocks      = optional(list(string))
    ssh_prefix_list_ids  = optional(list(string))
  })
}

variable "eks_http_proxy" {
  type = string
}

variable "eks_api_endpoint_access_cidrs" {
  type = list(object({
    from        = string
    port        = string
    description = string
  }))
  default = []
}