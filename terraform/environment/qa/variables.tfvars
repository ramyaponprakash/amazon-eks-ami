###############################################
#  Environment file for qa cluster creation
#
################################################
cluster_vpc                   = "vpc-003eb242be457b803"
aws_account                   = "342446142760"
cluster_name                  = "sdx-qa-eks-blue-cluster"
cluster_version               = 1.22
cluster_kms_key_arn           = "arn:aws:kms:ap-southeast-1:342446142760:key/c706f705-9a56-44f7-9db8-47364dfa93a6"
environment                   = "qa"
region                        = "ap-southeast-1"
instance_type                 = "t3.medium"
instance_type_bastion         = "t2.medium"
vpc_bastion_security_group    = ["sg-09613f28d186c3a15"]
sense_key                     = "sdx-qa"
subnet_ids                    = ["subnet-035ddd7b744cd4a59", "subnet-056a36371f1158557"] #private
endpoint_private_access       = true
endpoint_public_access        = false
subnet_id_bastion             = "subnet-049e25873d77ab992" # 3a, public rt
eks_cw_loggroup               = "sdx-qa-eks-blue-cluster"
cluster_log_kms_key_id        = "arn:aws:kms:ap-southeast-1:342446142760:key/c706f705-9a56-44f7-9db8-47364dfa93a6"
bastion_ami                   = "ami-02ee763250491e04a"
cidr_blocks_bastion_ssh       = ["173.2.1.128/25"] # 3a cidr, public rt
prefix_list_ids_bastion_ssh   = ["pl-0af10fe06357d6aff"]
kubectl_version               = "1.22.6/2022-03-09"
helm_version                  = "v3.9.2"
helmfile_version              = "0.145.2"
kube_proxy_version            = "v1.22.11-eksbuild.2"
vpc_cni_version               = "v1.10.1-eksbuild.1"
coredns_version               = "v1.8.7-eksbuild.1"
cidr_blocks_additional_secgrp = ["173.1.0.0/19", "173.2.0.0/19"]
