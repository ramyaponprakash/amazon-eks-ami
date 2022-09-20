variable "cluster_name" {
  description = "Cluster name"
}

variable "environment" {
  type = string
}

variable "default_nodegroup_asg" {
  description = "default_nodegroup_asg"
  type        = list(string)
}
