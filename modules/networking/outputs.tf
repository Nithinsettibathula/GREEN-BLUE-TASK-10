# --- Outputs ---
output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "blue_tg_arn" {
  value = aws_lb_target_group.blue.arn
}

output "blue_tg_name" {
  value = aws_lb_target_group.blue.name
}

output "green_tg_name" {
  value = aws_lb_target_group.green.name
}