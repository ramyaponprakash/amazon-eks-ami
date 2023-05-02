variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr_pri" {
  type = string
}

variable "vpc_cidr_sec" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "If network.create_vpc=false, it must be provided"
}

variable "vpc_private_subnets" {
  type = list(object({
    cidr       = string
    enable_elb = number
  }))
  default = []
}

variable "squid" {
  type = object({
    enable         = optional(bool, true)
    instance_type  = optional(string, "t3.medium")
    subnet_ids     = list(string)
    subnet_gw_ids  = list(string)
    zone_id        = string
    ami_squid      = string
    record_name    = string
    squid_key_name = string
    iam_role       = string
    kms_key_id     = string
  })
}

variable "squid_secgrp_ingress_cidr" {
  type = list(object({
    id          = string
    cidrs       = list(string)
    from_port   = number
    to_port     = number
    description = string
  }))

  default = []
}

variable "squid_secgrp_ingress_secgrp" {
  type = list(object({
    id          = string
    secgrp_id   = string
    from_port   = number
    to_port     = number
    description = string
  }))

  default = []
}
