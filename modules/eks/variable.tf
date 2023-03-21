variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "cluster_name" {
  type = string
}

variable "k8s_master_version" {
  type        = string
  default     = "1.23"
  description = "The kubernetes version to use. Only used a creation time, ignored once the cluster exists."
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "bastion_security_group_id" {
  type    = string
  default = ""
}

variable "eks_private_subnet_ids" {
  type = list(string)
}

variable "eks_customer_cmk_key_arn" {
  type    = string
  default = ""
}

variable "eks_node_group_iam_role_arns" {
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

variable "eks_cluster_endpoint_private" {
  type    = bool
  default = true
}