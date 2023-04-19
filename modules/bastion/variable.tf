variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "az_map" {
  type = map(any)
  default = {
    0 = "a"
    1 = "b"
    2 = "c"
  }
}

variable "bastion" {
  type = object({
    enable               = optional(bool, true)
    ami_id				 = optional(string, "ami-08b59d681971c7542")
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

    // cli installation variables
    kubectl_version  = optional(string, "1.22.6/2022-03-09")
    helm_version     = optional(string, "v3.9.2")
    helmfile_version = optional(string, "0.145.2")
  })
}
