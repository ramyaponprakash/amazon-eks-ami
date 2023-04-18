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

variable "eks_private_subnet_ids" {
  type = list(string)
}

variable "eks_customer_cmk_key_arn" {
  type = string
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

variable "eks_http_proxy" {
  type = string
}

variable "eks_private_ep_no_proxy" {
  type    = string
  default = "s3.amazonaws.com,.s3.ap-southeast-1.amazonaws.com,sts.ap-southeast-1.amazonaws.com,ec2.ap-southeast-1.amazonaws.com,.dkr.ecr.ap-southeast-1.amazonaws.com,api.ecr.ap-southeast-1.amazonaws.com,autoscaling.ap-southeast-1.amazonaws.com,logs.ap-southeast-1.amazonaws.com,eks.ap-southeast-1.amazonaws.com,elasticloadbalancing.ap-southeast-1.amazonaws.com"
}

variable "eks_additional_no_proxy" {
  type        = string
  description = "must start with starting comma"
  default     = ""
}

variable "eks_api_endpoint_access_cidrs" {
  type = list(object({
    from        = string
    port        = string
    description = string
  }))
  default = []
}