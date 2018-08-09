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
  version = "0.1.1"

  name_prefix                       = "${var.name_prefix}"
  vpc_id                            = "${var.vpc_id}"
  cluster_id                        = "${aws_ecs_cluster.cluster.id}"
  desired_count                     = "${var.desired_count}"
  task_container_image              = "${var.task_container_image}"
  task_container_port               = "${var.task_container_port}"
  task_container_protocol           = "${var.task_container_protocol}"
  task_container_environment_count  = "${var.task_container_environment_count}"
  task_container_environment        = "${var.task_container_environment}"
  task_container_assign_public_ip   = "${var.task_container_assign_public_ip}"
  task_definition_cpu               = "${var.task_definition_cpu}"
  task_definition_memory            = "${var.task_definition_memory}"
  lb_arn                            = "${var.alb_arn}"
  private_subnet_ids                = "${var.private_subnet_ids}"
  health_check_grace_period_seconds = "${var.health_check_grace_period_seconds}"

  health_check {
    port    = "traffic-port"
    path    = "/api/health"
    matcher = "200"
  }

  tags = "${var.tags}"
}

# ----------------------------------------
# AWS IAM Role Policy
# ----------------------------------------

resource "aws_iam_role_policy_attachment" "ssmtotask" {
  policy_arn = "${aws_iam_policy.grafana-task-pol.arn}"
  role       = "${module.grafana.task_role_name}"

  # tags not supported for aws_iam_role_policy_attachment
}
