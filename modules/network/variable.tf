variable "network" {
  type = object({
    enable     = optional(bool, true)
    create_vpc = optional(bool, false)
  })
  description = "Base config to enable/disable module. create_vpc=false will skip vpc creation."
}

variable "vpc_eip" {
  type = object({
    enable_eip = optional(bool, true)
    count      = number
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

variable "vpc_enable_private" {
  type    = bool
  default = false
}

variable "vpc_nat_gateway" {
  type = object({
    enable = optional(bool, true)
  })
}

variable "vpc_igw" {
  type = object({
    enable_igw = optional(bool, false)
    count      = number
  })
}


variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name will be tagged to vpc and subnets for auto discovery by elb and ingress controller"
}

variable "vpc_name" {
  type = string
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "If network.create_vpc=false, it must be provided"
}

variable "vpc_cidr" {
  type    = string
  default = ""
}

variable "vpc_secondary_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "vpc_excluded_zone_names" {
  type        = list(string)
  default     = []
  description = "Network module will use all available availability zones in the region, adding zones to this list will exclude them."
}

variable "vpc_public_subnets" {
  type = list(object({
    cidr       = string
    enable_elb = number
  }))
  default = [
    {
      cidr       = "10.0.10.0/24"
      enable_elb = 1
    },
    {
      cidr       = "10.0.11.0/24"
      enable_elb = 1
    },
    {
      cidr       = "10.0.12.0/24"
      enable_elb = 0 // Don't attach the ELB to the monitor AZ
    }
  ]
}

variable "vpc_private_subnets" {
  type = list(object({
    cidr       = string
    enable_elb = number
  }))
  default = [
    {
      cidr       = "10.0.0.0/24"
      enable_elb = 1
    },
    {
      cidr       = "10.0.1.0/24"
      enable_elb = 1
    },
    {
      cidr       = "10.0.2.0/24"
      enable_elb = 0 // Don't attach the ELB
    }
  ]
}

variable "vpc_private_elb_subnets" {
  type = list(object({
    cidr       = string
    enable_elb = number
  }))
  default = []
}

variable "vpc_nat_gw_eip_allocation_ids" {
  type    = list(string)
  default = []
}

variable "vpc_nat_gw_ids" {
  type    = list(string)
  default = []
}

variable "vpc_igw_ids" {
  type    = list(string)
  default = []
}

variable "az_map" {
  type = map(any)
  default = {
    0 = "a"
    1 = "b"
    2 = "c"
  }
}
