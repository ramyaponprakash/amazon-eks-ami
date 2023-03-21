output "bastion_instance_id" {
  value = var.bastion.enable ? module.bastion[0].bastion_instance_id : ""
}

output "bastion_generated_ssh_public_key" {
  value     = var.bastion.enable ? module.bastion[0].generated_ssh_public_key : ""
  sensitive = true
}

output "bastion_generated_ssh_private_key" {
  value     = var.bastion.enable ? module.bastion[0].generated_ssh_private_key : ""
  sensitive = true
}

output "vpc_id" {
  value = var.eks_network.enable ? module.eks_network[0].vpc_id : ""
}
