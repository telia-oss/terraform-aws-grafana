# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

variable "name_prefix" {
  description = "A prefix used for naming resources."
}

variable "vpc_id" {
  description = "The ID of the VPC that this container will run in, needed for the Target Group."
}

variable "private_subnet_ids" {
  description = "A list of private subnets inside the VPC"
  type        = "list"
}

variable "alb_arn" {
  description = "Arn for the ALB for which the service should be attach to."
}

variable "task_container_image" {
  description = "Image for the task definition (repo:tag or repo@digest)."
  default     = "grafana/grafana"
}

variable "task_container_port" {
  description = "Port that the container exposes."
  default     = 3000
}

variable "task_container_protocol" {
  description = "Protocol that the container exposes."
  default     = "HTTP"
}

variable "desired_count" {
  description = "The dsfsfdf."
  default     = 1
}

variable "task_definition_cpu" {
  description = "Amount of CPU to reserve for the task."
  default     = "256"
}

variable "task_definition_memory" {
  description = "The soft limit (in MiB) of memory to reserve for the container."
  default     = "512"
}

variable "task_container_command" {
  description = "The command that is passed to the container."
  default     = []
}

variable "log_retention_in_days" {
  description = "Number of days the logs will be retained in CloudWatch."
  default     = "30"
}

variable "task_container_environment" {
  description = "The environment variables to pass to a container."
  default     = {}
}

variable "task_container_environment_count" {
  description = "NOTE: This exists purely to calculate count in Terraform. Should equal the length of your environment map."
  default     = "0"
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = "map"
  default     = {}
}

variable "health_check_grace_period_seconds" {
  default     = "300"
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers."
}

variable "task_container_assign_public_ip" {
  description = "Assigned public IP to the container."
  default     = "false"
}
