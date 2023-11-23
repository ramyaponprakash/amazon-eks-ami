###############################################
#  Environment file for dev cluster creation
#
################################################
cluster_vpc                   = "vpc-00721a287031db6a2"
aws_account                   = "342446142760"
cluster_name                  = "adex-dev-eks-blue-cluster"
cluster_version               = 1.26
cluster_kms_key_arn           = "arn:aws:kms:ap-southeast-1:342446142760:key/c706f705-9a56-44f7-9db8-47364dfa93a6"
region                        = "ap-southeast-1"
environment                   = "dev"
instance_type                 = "t3.medium"
instance_type_bastion         = "t2.medium"
sense_key                     = "snsp-poc"
vpc_bastion_security_group    = ["sg-04389d1c99970c14d"]
subnet_ids                    = ["subnet-0c683d5359992221c", "subnet-03ae8ba0f4c5a7369"]
endpoint_private_access       = true
endpoint_public_access        = false
subnet_id_bastion             = "subnet-0e57510f81a0cd5a2"
cluster_log_kms_key_id        = "arn:aws:kms:ap-southeast-1:342446142760:key/c706f705-9a56-44f7-9db8-47364dfa93a6"
eks_cw_loggroup               = "adex-dev-eks-blue-cluster"
bastion_ami                   = "ami-02ee763250491e04a"
cidr_blocks_bastion_ssh       = ["172.1.0.0/16"]
prefix_list_ids_bastion_ssh   = ["pl-0af10fe06357d6aff"]
kubectl_version               = "1.22.6/2022-03-09"
helm_version                  = "v3.9.2"
helmfile_version              = "0.145.2"
kube_proxy_version            = "v1.23.8-eksbuild.2"
vpc_cni_version               = "v1.11.4-eksbuild.1"
coredns_version               = "v1.8.7-eksbuild.2"
cidr_blocks_additional_secgrp = ["172.2.0.0/19"]
