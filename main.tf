# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------

locals {
  task_container_port = 3000
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# ----------------------------------------
# ECS Cluster
# ----------------------------------------
resource "aws_ecs_cluster" "cluster" {
  name = "${var.name_prefix}-ecs-cluster"
}

# ----------------------------------------
# Security groups
# ----------------------------------------

resource "aws_security_group_rule" "ingress_task" {
  security_group_id        = "${module.grafana.service_sg_id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${local.task_container_port}"
  to_port                  = "${local.task_container_port}"
  source_security_group_id = "${var.alb_sg}"
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

# ----------------------------------------
# Listener rule
# ----------------------------------------

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = "${var.alb_listener_arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${module.grafana.target_group_arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/grafana*"]
  }
}
