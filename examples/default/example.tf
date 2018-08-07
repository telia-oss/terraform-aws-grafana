provider "aws" {
  version = "1.20.0"
  region  = "eu-west-1"
}

locals {
  name_prefix = "grafana-test"
  username    = "admin"
  password    = "changeme"

  auth_github_enabled               = false
  auth_github_client_id             = "id"
  auth_github_client_secret         = "secret"
  auth_github_allowed_organisations = "telia-oss"
  auth_github_allow_signup          = false
  task_container_port               = 3000
  rds_instance_type                 = "db.m3.medium"
  rds_instance_engine               = "postgres"
  rds_instance_multi_az             = false
  rds_instance_port                 = "5432"
  rds_instance_username             = "root"
  rds_instance_password             = "changeme"
  desired_count                     = 1

  tags = {
    terraform   = "true"
    environment = "stage"
    application = "grafana"
  }
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet_ids" "main" {
  vpc_id = "${data.aws_vpc.main.id}"
}

module "alb" {
  source  = "telia-oss/loadbalancer/aws"
  version = "0.1.0"

  name_prefix = "${local.name_prefix}"
  type        = "application"
  internal    = "true"
  vpc_id      = "${data.aws_vpc.main.id}"
  subnet_ids  = "${data.aws_subnet_ids.main.ids}"

  tags {
    environment = "test"
    terraform   = "true"
  }
}

module "rds-instance" {
  source  = "telia-oss/rds-instance/aws"
  version = "0.1.1"

  name_prefix   = "${local.name_prefix}"
  username      = "${local.rds_instance_username}"
  password      = "${local.rds_instance_password}"
  database_name = "grafana"
  subnet_ids    = "${data.aws_subnet_ids.main.ids}"
  vpc_id        = "${data.aws_vpc.main.id}"
  port          = "${local.rds_instance_port}"
  engine        = "${local.rds_instance_engine}"
  instance_type = "${local.rds_instance_type}"
  multi_az      = "${local.rds_instance_multi_az}"
}

module "grafana" {
  source      = "../../"
  name_prefix = "${local.name_prefix}"
  vpc_id      = "${data.aws_vpc.main.id}"

  desired_count      = "${local.desired_count}"
  private_subnet_ids = "${data.aws_subnet_ids.main.ids}"
  tags               = "${local.tags}"
  alb_arn            = "${module.alb.arn}"

  task_container_environment = {
    "GF_DATABASE_TYPE"                     = "${local.rds_instance_engine}"
    "GF_DATABASE_USER"                     = "${local.rds_instance_username}"
    "GF_DATABASE_PASSWORD"                 = "${local.rds_instance_password}"
    "GF_DATABASE_HOST"                     = "${module.rds-instance.endpoint}"
    "GF_SECURITY_ADMIN_USER"               = "${local.username}"
    "GF_SECURITY_ADMIN_PASSWORD"           = "${local.password}"
    "GF_AUTH_GITHUB_ENABLED"               = "${local.auth_github_enabled}"
    "GF_AUTH_GITHUB_CLIENT_ID"             = "${local.auth_github_client_id}"
    "GF_AUTH_GITHUB_CLIENT_SECRET"         = "${local.auth_github_client_secret}"
    "GF_AUTH_GITHUB_ALLOWED_ORGANISATIONS" = "${local.auth_github_allowed_organisations}"
    "GF_AUTH_GITHUB_ALLOW_SIGN_UP"         = "${local.auth_github_allow_signup}"
  }

  task_container_environment_count = "11"
}

# ----------------------------------------
# Security groups
# ----------------------------------------

resource "aws_security_group_rule" "ingress_task" {
  security_group_id        = "${module.alb.security_group_id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${local.task_container_port}"
  to_port                  = "${local.task_container_port}"
  source_security_group_id = "${module.grafana.service_sg_id}"
}

# ----------------------------------------
# ALB Listener
# ----------------------------------------
resource "aws_lb_listener" "main" {
  load_balancer_arn = "${module.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${module.grafana.target_group_arn}"
  }
}
