# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

variable "alb_arn" {
  description = "Arn for the ALB for which the service should be attach to."
}

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
  type        = "list"
  default     = []
}

variable "task_container_environment" {
  description = "The environment variables to pass to a container."
  type        = "map"
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

variable "rds_instance_type" {
  description = "The db instance type to be used for the database"
  default     = "db.t2.small"
}

variable "rds_instance_storage" {
  description = "The ammount of storage space to allocate to the database (GB)"
  default     = "10"
}

variable "cluster_id" {
  description = "The ID of the cluster into which this service will be lauched"
}

variable "parameters_key_arn" {
  description = "The ARN of the kms key used to encrypt the parameters"
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
}

variable "route53_zone" {
  description = "The name of the route53 zone that this service should be registered in"
}
