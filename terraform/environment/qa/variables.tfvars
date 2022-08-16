###############################################
#  Environment file for qa cluster creation
#
################################################
cluster_blue_name            = "sdx-qa-eks-blue-cluster"
sense_vpc                    = "vpc-09a58d6d"
aws_account                  = "342446142760"
cluster_name                 = "sdx-qa-eks-blue-cluster"
cluster_version              = 1.23
environment                  = "qa"
instance_type                = "t3.medium"
sense_key                    = "sdx-qa"
subnet_ids                   = ["subnet-0459927e5a9a8ba64", "subnet-0e1e99fe7c3dbd3f9"]
eks_cw_loggroup              = "sdx-qa-eks-blue-cluster"



