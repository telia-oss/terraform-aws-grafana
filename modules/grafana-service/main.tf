# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# ----------------------------------------
# RDS Cluster
# ----------------------------------------
data "aws_ssm_parameter" "grafana_rds_username" {
  name = "/${var.name_prefix}/rds-username"
}

data "aws_ssm_parameter" "grafana_rds_password" {
  name = "/${var.name_prefix}/rds-password"
}

module "grafana_rds" {
  source  = "telia-oss/rds-instance/aws"
  version = "3.0.0"

  name_prefix         = var.name_prefix
  username            = data.aws_ssm_parameter.grafana_rds_username.value
  password            = data.aws_ssm_parameter.grafana_rds_password.value
  database_name       = "grafana"
  subnet_ids          = var.private_subnet_ids
  vpc_id              = var.vpc_id
  port                = 5432
  engine              = "postgres"
  instance_type       = var.rds_instance_type
  allocated_storage   = var.rds_instance_storage
  multi_az            = false
  skip_final_snapshot = false
  snapshot_identifier = var.snapshot_identifier
  tags                = var.tags
}

# ----------------------------------------
# Grafana ECS Fargate Service
# ----------------------------------------
# Note: The provider cannot be removed without having a "migration release" since it was included in the first place.
# Attempts to do so will produce the following error: "Error: Provider configuration not present"
provider "null" {}

module "grafana-service" {
  source  = "telia-oss/ecs-fargate/aws"
  version = "3.1.0"

  name_prefix             = var.name_prefix
  vpc_id                  = var.vpc_id
  cluster_id              = var.cluster_id
  task_container_image    = "teliaoss/grafana-aws-env:5.4.3"
  task_container_port     = 3000
  task_container_protocol = "HTTP"

  task_container_environment = {
    "AWS_REGION"                           = data.aws_region.current.name
    "GF_SERVER_ROOT_URL"                   = "ssm://${aws_ssm_parameter.grafana_root_url.name}"
    "GF_DATABASE_HOST"                     = "ssm://${aws_ssm_parameter.grafana_rds_host.name}"
    "GF_DATABASE_TYPE"                     = "postgres"
    "GF_DATABASE_USER"                     = "ssm://${data.aws_ssm_parameter.grafana_rds_username.name}"
    "GF_DATABASE_PASSWORD"                 = "ssm://${data.aws_ssm_parameter.grafana_rds_password.name}"
    "GF_SECURITY_ADMIN_USER"               = "ssm:///${var.name_prefix}/admin-user-name"
    "GF_SECURITY_ADMIN_PASSWORD"           = "ssm:///${var.name_prefix}/admin-user-password"
    "GF_AUTH_GITHUB_ENABLED"               = "ssm:///${var.name_prefix}/github-auth-enabled"
    "GF_AUTH_GITHUB_CLIENT_ID"             = "ssm:///${var.name_prefix}/github-client-id"
    "GF_AUTH_GITHUB_CLIENT_SECRET"         = "ssm:///${var.name_prefix}/github-client-secret"
    "GF_AUTH_GITHUB_ALLOWED_ORGANISATIONS" = "ssm:///${var.name_prefix}/github-allowed-organisations"
    "GF_AUTH_GITHUB_ALLOW_SIGN_UP"         = "true"
  }

  task_definition_cpu               = var.task_definition_cpu
  task_definition_memory            = var.task_definition_memory
  lb_arn                            = var.alb_arn
  private_subnet_ids                = var.private_subnet_ids
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  health_check = {
    port    = "traffic-port"
    path    = "/api/health"
    matcher = "200"
  }

  tags = var.tags
}

# ----------------------------------------
# AWS IAM Role Policy
# ----------------------------------------
resource "aws_iam_role_policy_attachment" "ssmtotask" {
  policy_arn = aws_iam_policy.grafana-task-pol.arn
  role       = module.grafana-service.task_role_name
}

resource "aws_iam_role_policy_attachment" "kmstotask" {
  policy_arn = aws_iam_policy.kmsfortaskpol.arn
  role       = module.grafana-service.task_role_name
}

resource "aws_iam_role_policy_attachment" "ststotask" {
  policy_arn = aws_iam_policy.stsfortaskpol.arn
  role       = module.grafana-service.task_role_name
}

resource "aws_iam_role_policy_attachment" "cloudwatchtotask" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  role       = module.grafana-service.task_role_name
}

resource "aws_security_group_rule" "grafana_rds_ingress" {
  security_group_id        = module.grafana_rds.security_group_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = module.grafana_rds.port
  to_port                  = module.grafana_rds.port
  source_security_group_id = module.grafana-service.service_sg_id
}

# ----------------------------------------
# SSM Paramter Configuration
# ----------------------------------------
data "aws_route53_zone" "aws_route53_zone" {
  name         = var.route53_zone
  private_zone = false
}

resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.aws_route53_zone.id
  name    = "${var.name_prefix}.${data.aws_route53_zone.aws_route53_zone.name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name]
}

resource "aws_ssm_parameter" "grafana_rds_host" {
  name      = "/${var.name_prefix}/rds-url"
  type      = "SecureString"
  value     = module.grafana_rds.endpoint
  key_id    = var.parameters_key_arn
  overwrite = true
}

resource "aws_ssm_parameter" "grafana_root_url" {
  name      = "/${var.name_prefix}/base-url"
  type      = "SecureString"
  value     = "https://${aws_route53_record.grafana.fqdn}"
  key_id    = var.parameters_key_arn
  overwrite = true
}
