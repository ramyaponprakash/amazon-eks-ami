###############################################
#  Environment file for intra cluster creation
#
################################################
cluster_blue_name            = "sdx-intra-eks-blue-cluster"
sense_vpc                    = "vpc-09a58d6d"
aws_account                  = "726262972162"
cluster_name                 = "sdx-intra-eks-blue-cluster"
cluster_version              = 1.23
environment                  = "intra"
instance_type                = "t3.medium"
sense_key                    = "sdx-intra-prd"
eks_cluster_subnet_ids       = ["subnet-0459927e5a9a8ba64", "subnet-0e1e99fe7c3dbd3f9"]
eks_nodegroup_subnet_ids     = ["subnet-75629d12","subnet-eb8f6da2"]
eks_cw_loggroup              = "sdx-intra-eks-blue-cluster"



