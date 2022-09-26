variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "cluster_kms_key_arn" {
  type = string
}

variable "kubectl_version" {
  description = "Kubectl version to use for the EKS cluster."
  type        = string
}

variable "helm_version" {
  description = "helm version to use for the EKS cluster."
  type        = string
}

variable "helmfile_version" {
  description = "helmfile version to use for the EKS cluster."
  type        = string
}

variable "kube_proxy_version" {
  description = "helmfile version to use for the EKS cluster."
  type        = string
}

variable "vpc_cni_version" {
  description = "helmfile version to use for the EKS cluster."
  type        = string
}

variable "coredns_version" {
  description = "helmfile version to use for the EKS cluster."
  type        = string
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}

variable "cluster_vpc" {
  description = "vpc"
  type        = string
}

variable "aws_account" {
  description = "AWS account"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "cluster_log_retention_in_days" {
  default     = 90
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = string
}

variable "cluster_log_kms_key_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_type_bastion" {
  type = string
}

variable "sense_key" {
  type = string
}

variable "ng_desired_size" {
  description = "nodegroup_desired_size"
  default     = 4
  type        = number
}

variable "ng_max_size" {
  description = "nodegroup_max_size"
  default     = 7
  type        = number
}

variable "ng_min_size" {
  description = "nodegroup_min_size"
  default     = 3
  type        = number
}

variable "region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "subnet_ids" {
  description = "eks_cluster_subnet_ids"
  type        = list(any)
}

variable "subnet_id_bastion" {
  description = "vpc-subnet-bastion"
  type        = string
}

variable "endpoint_private_access" {
  description = "endpoint_private_access"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "endpoint_public_access"
  type        = bool
  default     = false
}

variable "eks_cw_loggroup" {
  description = "eks cloudwatch loggroup"
  type        = string
}

variable "bastion_ami" {
  description = "bastion host ami"
  type        = string
}

variable "cidr_blocks_bastion_ssh" {
  description = "A list of CIDR blocks to allow traffic"
  type        = list(any)
}

variable "prefix_list_ids_bastion_ssh" {
  description = "A list of CIDR blocks to allow traffic from prefix_list_ids"
  type        = list(any)
}

variable "cidr_blocks_additional_secgrp" {
  description = "A list of vpc CIDR blocks to allow traffic for additional security group"
  type        = list(any)
}