output "bastion-host" {
  value = aws_instance.bastion
}

output "bastion_instance_id" {
  value = aws_instance.bastion[var.bastion.hosts_number - 1].id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_security_group.id
}

output "bastion-host-public-ip" {
  value = aws_instance.bastion.*.public_ip
}

output "bastion-iam_role_arn" {
  value = data.aws_iam_role.bastion_ec2_role.arn
}
