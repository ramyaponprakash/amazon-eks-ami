output "bastion-host" {
  value = aws_instance.ubuntu_bastion
}

output "generated_ssh_public_key" {
  value = var.bastion.generate_private_key ? tls_private_key.generated_sshkey[0].public_key_openssh : null
}

output "generated_ssh_private_key" {
  value     = var.bastion.generate_private_key ? tls_private_key.generated_sshkey[0].private_key_pem : null
  sensitive = true
}

output "bastion_instance_id" {
  value = aws_instance.ubuntu_bastion[var.bastion.hosts_number - 1].id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_security_group.id
}

output "bastion_eip_id" {
  value = var.bastion.attach_eip ? [aws_eip.ubuntu_bastion_eip[0].id] : []
}

output "bastion-host-public-ip" {
  value = aws_instance.ubuntu_bastion.*.public_ip
}
