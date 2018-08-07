# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# ----------------------------------------
# ECS Cluster
# ----------------------------------------
resource "aws_ecs_cluster" "cluster" {
  name = "${var.name_prefix}-ecs-cluster"
}

# ----------------------------------------
# Grafana ECS Fargate Service
# ----------------------------------------

module "grafana" {
  source  = "telia-oss/ecs-fargate/aws"
  version = "0.1.0"

  name_prefix                      = "${var.name_prefix}"
  vpc_id                           = "${var.vpc_id}"
  cluster_id                       = "${aws_ecs_cluster.cluster.id}"
  desired_count                    = "${var.desired_count}"
  task_container_image             = "${var.task_container_image}"
  task_container_port              = "${var.task_container_port}"
  task_container_protocol          = "${var.task_container_protocol}"
  task_container_environment_count = "${var.task_container_environment_count}"
  task_container_environment       = "${var.task_container_environment}"
  lb_arn                           = "${var.alb_arn}"
  private_subnet_ids               = "${var.private_subnet_ids}"

  // CPU
  // Memory

  health_check {
    port    = "traffic-port"
    path    = "/api/health"
    matcher = "200"
  }
  tags = "${var.tags}"
}
