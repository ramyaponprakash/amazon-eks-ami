###############################################
#  Environment file for prd cluster creation
#
################################################
sense_vpc                   = "vpc-09a58d6d"
aws_account                 = "726262972162"
cluster_name                = "sdx-prd-eks-blue-cluster"
cluster_version             = 1.22
environment                 = "prd"
instance_type               = "t3.medium"
instance_type_bastion       = "t2.medium"
sense_key                   = "sdx-prd"
subnet_ids                  = ["subnet-0459927e5a9a8ba64", "subnet-0e1e99fe7c3dbd3f9"]
subnet_id_bastion           = "subnet-0eaa789d06887eda5"
eks_cw_loggroup             = "sdx-prd-eks-blue-cluster"
bastion_ami                 = "ami-02ee763250491e04a"
cidr_blocks_bastion_ssh     = ["172.31.16.0/24"]
prefix_list_ids_bastion_ssh = ["pl-0af10fe06357d6aff"]



