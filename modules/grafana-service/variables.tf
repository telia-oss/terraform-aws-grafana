# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

variable "alb_arn" {
  description = "Arn for the ALB for which the service should be attach to."
  type        = string
}

variable "name_prefix" {
  description = "A prefix used for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC that this container will run in, needed for the Target Group."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "snapshot_identifier" {
  description = "The identifier of the snapshot to create the database from - if left empty a new db will be created"
  type        = string
  default     = ""
}

variable "task_definition_cpu" {
  description = "Amount of CPU to reserve for the task."
  type        = number
  default     = 256
}

variable "task_definition_memory" {
  description = "The soft limit (in MiB) of memory to reserve for the container."
  type        = number
  default     = 512
}

variable "task_container_command" {
  description = "The command that is passed to the container."
  type        = list(string)
  default     = []
}

variable "task_container_environment" {
  description = "The environment variables to pass to a container."
  type        = map(string)
  default     = {}
}

variable "task_container_environment_count" {
  description = "NOTE: This exists purely to calculate count in Terraform. Should equal the length of your environment map."
  type        = number
  default     = 0
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers."
  type        = number
  default     = 300
}

variable "rds_instance_type" {
  description = "The db instance type to be used for the database"
  type        = string
  default     = "db.t2.small"
}

variable "rds_instance_storage" {
  description = "The ammount of storage space to allocate to the database (GB)"
  type        = number
  default     = 10
}

variable "cluster_id" {
  description = "The ID of the cluster into which this service will be lauched"
  type        = string
}

variable "parameters_key_arn" {
  description = "The ARN of the kms key used to encrypt the parameters"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
}

variable "route53_zone" {
  description = "The name of the route53 zone that this service should be registered in"
  type        = string
}

