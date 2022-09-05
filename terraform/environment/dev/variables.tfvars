###############################################
#  Environment file for dev cluster creation
#
################################################
#cluster_blue_name            = "sdx-dev-eks-blue-cluster"
sense_vpc                    = "vpc-09a58d6d"
aws_account                  = "342446142760"
cluster_name                 = "sdx-dev-eks-blue-cluster"
cluster_version              = 1.23
environment                  = "dev"
instance_type                = "t3.medium"
instance_type_bastion        = "t2.medium"
sense_key                    = "snsp-poc"
subnet_ids                   = ["subnet-0459927e5a9a8ba64", "subnet-0e1e99fe7c3dbd3f9"]
subnet_id_bastion            = "subnet-0eaa789d06887eda5"
eks_cw_loggroup              = "sdx-dev-eks-blue-cluster"
ami                          = "ami-02ee763250491e04a"
cidr_blocks_bastion_ssh      = ["172.31.16.0/24"]
prefix_list_ids_bastion_ssh  = ["pl-0af10fe06357d6aff"]
kubectl_version              =  "1.22.6/2022-03-09"
helm_version                 = "v3.9.2"
helmfile_version             = "0.145.2"



