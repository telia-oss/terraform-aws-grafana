# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------
output "target_group_arn" {
  description = "The ARN of the Target Group."
  value       = module.grafana-service.target_group_arn
}

output "service_sg_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service security group."
  value       = module.grafana-service.service_sg_id
}

output "task_role_name" {
  description = "The name of the service role."
  value       = module.grafana-service.task_role_name
}

