variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "environment" {
  type = string
}

variable "default_nodegroup_asg" {
  description = "default_nodegroup_asg"
  type        = set(string)
}
