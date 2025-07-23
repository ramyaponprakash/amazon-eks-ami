output "squid_nlb_solace_arn" {
  value = aws_lb.squid_nlb.arn
}

output "squid_nlb_solace_ecs_tg_arn" {
  value = aws_lb_target_group.squid_nlb_solace_ecs_tg.arn
}