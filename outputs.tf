# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------

output "grafana_URL" {
  value = "https://fix.me"
}

output "target_group_arn" {
  description = "The ARN of the Target Group."
  value       = "${module.grafana.target_group_arn}"
}

output "service_sg_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service security group."
  value       = "${module.grafana.service_sg_id}"
}
