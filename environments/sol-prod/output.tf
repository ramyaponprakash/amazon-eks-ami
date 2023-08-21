output "bastion_instance_id" {
  value = var.bastion.enable ? module.bastion[0].bastion_instance_id : ""
}

output "vpc_id" {
  value = var.network.enable ? module.eks_network[0].vpc_id : ""
}
