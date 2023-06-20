variable "cluster_name" {
  type = string
}

variable "eks_node_role_name" {
  type = string
}

variable "eks_node_role_arn" {
  type = string
}

variable "eks_private_subnet_ids" {
  type = list(string)
}

variable "node_groups_count_messaging" {
  type        = number
  default     = 2
  description = "The number of messaging node groups for each service class (one for each zone)."
}

variable "node_groups_settings_messaging" {
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
  default = {
    desired_size = 0
    min_size     = 0
    max_size     = 50
  }
}

variable "node_groups_1k_instance_type" {
  type    = string
  default = "r5.large"
}

variable "node_groups_10k_instance_type" {
  type    = string
  default = "r5.xlarge"
}

variable "node_groups_100k_instance_type" {
  type    = string
  default = "r5.2xlarge"
}

variable "node_groups_monitoring_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "asg_messaging_tags" {
  type = list(object({
    type  = string
    key   = string
    value = string
  }))

  default = [
    {
      type  = "resources"
      key   = "ephemeral-storage"
      value = "20G"
    }
  ]
}

variable "labels_taints_monitoring" {
  type = object({
    labels = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  })

  default = {
    labels = {
      nodeType = "monitoring"
    }
    taints = [
      {
        key    = "nodeType"
        value  = "monitoring"
        effect = "NO_EXECUTE"
      }
    ]
  }
}

variable "labels_taints_prod1k" {
  type = object({
    labels = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  })

  default = {
    labels = {
      nodeType     = "messaging"
      serviceClass = "prod1k"
    }
    taints = [
      {
        key    = "nodeType"
        value  = "messaging"
        effect = "NO_EXECUTE"
      },
      {
        key    = "serviceClass"
        value  = "prod1k"
        effect = "NO_EXECUTE"
      }
    ]
  }
}

variable "labels_taints_prod10k" {
  type = object({
    labels = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  })

  default = {
    labels = {
      nodeType     = "messaging"
      serviceClass = "prod10k"
    }
    taints = [
      {
        key    = "nodeType"
        value  = "messaging"
        effect = "NO_EXECUTE"
      },
      {
        key    = "serviceClass"
        value  = "prod10k"
        effect = "NO_EXECUTE"
      }
    ]
  }
}

variable "labels_taints_prod100k" {
  type = object({
    labels = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  })

  default = {
    labels = {
      nodeType     = "messaging"
      serviceClass = "prod100k"
    }
    taints = [
      {
        key    = "nodeType"
        value  = "messaging"
        effect = "NO_EXECUTE"
      },
      {
        key    = "serviceClass"
        value  = "prod100k"
        effect = "NO_EXECUTE"
      }
    ]
  }
}

variable "vpc_id" {
  type = string
}

variable "eks_http_proxy" {
  type = string
}

variable "eks_private_ep_no_proxy" {
  type    = string
  default = "s3.amazonaws.com,.s3.ap-southeast-1.amazonaws.com,sts.ap-southeast-1.amazonaws.com,ec2.ap-southeast-1.amazonaws.com,.dkr.ecr.ap-southeast-1.amazonaws.com,api.ecr.ap-southeast-1.amazonaws.com,autoscaling.ap-southeast-1.amazonaws.com,logs.ap-southeast-1.amazonaws.com,eks.ap-southeast-1.amazonaws.com,elasticloadbalancing.ap-southeast-1.amazonaws.com,ssm.ap-southeast-1.amazonaws.com,ssmmessages.ap-southeast-1.amazonaws.com,ec2messages.ap-southeast-1.amazonaws.com"
}

variable "eks_additional_no_proxy" {
  type        = string
  description = "must start with starting comma"
  default     = ""
}

variable "cluster_node_secgrp_id" {
  type = list(string)
}