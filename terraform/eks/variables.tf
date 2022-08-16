variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
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

variable "sense_vpc" {
    description = "vpc"
}

variable "aws_account" {
    description = "AWS account"
}

variable "cluster_name" {
    description = "Cluster name"
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

variable "sense_key" {
  type    = string
}


variable "subnet_ids" {
    description = "eks_cluster_subnet_ids"
    type        = list
}

variable "eks_cw_loggroup" {
    description = "eks cloudwatch loggroup"
    type        = string
}


