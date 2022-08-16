variable "sense_vpc" {
    description = "vpc"
}

variable "aws_account" {
    description = "AWS account number"
}

variable "cluster_name" {
    description = "Cluster name"
  
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "cluster_log_retention_in_days" {
  default     = 90
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type    = string
}

variable "instance_type_bastion" {
  type    = string
}

variable "sense_key" {
  type    = string
}

variable "subnet_ids" {
    description = "eks_cluster_subnet_ids"
    type        = list
}

variable "subnet_id_bastion" {
    description = "vpc-subnet-bastion"
    type        = string
}

variable "eks_cw_loggroup" {
    description = "eks cloudwatch loggroup"
    type        = string
}

variable "ami" {
  description = "aws ami "
}

variable "cidr_blocks_bastion_ssh" {
  description = "A list of CIDR blocks to allow traffic"
  type        = list
}

variable "prefix_list_ids_bastion_ssh" {
  description = "A list of CIDR blocks to allow traffic from prefix_list_ids"
  type        = list
}
