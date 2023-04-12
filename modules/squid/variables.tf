variable "region" {
  type    = string
  default = "ap-southeast-1"
}


variable "vpc_name" {
  type = string
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
    subnet_ids     = list(object({ cidr = string, enable_elb = number }))
    ami_squid      = string
    squid_key_name = string
    iam_role       = string
    kms_key_id     = string
  })
}

 