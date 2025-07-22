// Name of the ECS cluster
variable "cluster_name" {
  type = string
}

// Number of instances of the cluster
variable "number_replicas" {
  type    = number
  default = 3
}

// Port to be used by squid proxy server
variable "squid_port" {
  type = number
  default = 3128
}

// nlb ARN
variable "nlb_arn" {
  type = string
}

// nlb target group for ECS
variable "nlb_ecs_tg_arn" {
  type = string
}

// Security groups to deply the Solace service in
variable "security_groups" {
  type = list(string)
}

// Subnet to deploy the service in
variable "solace_subnets" {
  type = list(string)
}

# Name of the container to be used in the ECS task definition
variable "container_name" {
  type = string
}
