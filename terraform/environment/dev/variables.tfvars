###############################################
#  Environment file for dev cluster creation
#
################################################
sense_vpc                     = "vpc-09a58d6d"
aws_account                   = "342446142760"
cluster_name                  = "sdx-dev-eks-blue-cluster"
cluster_version               = 1.22
region                        = "ap-southeast-1"
environment                   = "dev"
instance_type                 = "t3.medium"
instance_type_bastion         = "t2.medium"
sense_key                     = "snsp-poc"
vpc_bastion_security_group    = ["sg-097e5f2eaa6488c15"]
subnet_ids                    = ["subnet-0459927e5a9a8ba64", "subnet-0e1e99fe7c3dbd3f9"]
endpoint_private_access       = true
endpoint_public_access        = false
subnet_id_bastion             = "subnet-0eaa789d06887eda5"
eks_cw_loggroup               = "sdx-dev-eks-blue-cluster"
bastion_ami                   = "ami-02ee763250491e04a"
cidr_blocks_bastion_ssh       = ["172.31.16.0/24"]
prefix_list_ids_bastion_ssh   = ["pl-0af10fe06357d6aff"]
kubectl_version               = "1.22.6/2022-03-09"
helm_version                  = "v3.9.2"
helmfile_version              = "0.145.2"
kube_proxy_version            = "v1.22.11-eksbuild.2"
vpc_cni_version               = "v1.10.1-eksbuild.1"
coredns_version               = "v1.8.7-eksbuild.1"
cidr_blocks_additional_secgrp = ["172.31.0.0/16"]