provider "aws" {
  region = "eu-west-1"
}

locals {
  name_prefix     = "grafana-example"
  route53_zone    = "example.com"
  certificate_arn = "<ssl-certificate-arn>"

  tags = {
    terraform   = "true"
    environment = "example"
    application = "grafana"
  }
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet_ids" "main" {
  vpc_id = data.aws_vpc.main.id
}

module "alb" {
  source  = "telia-oss/loadbalancer/aws"
  version = "4.0.0"

  name_prefix = local.name_prefix
  type        = "application"
  vpc_id      = data.aws_vpc.main.id
  subnet_ids  = data.aws_subnet_ids.main.ids
  tags        = local.tags
}

resource "aws_ecs_cluster" "cluster" {
  name = "${local.name_prefix}-ecs-cluster"
}

module "grafana" {
  source             = "../../modules/grafana-service"
  name_prefix        = local.name_prefix
  vpc_id             = data.aws_vpc.main.id
  private_subnet_ids = data.aws_subnet_ids.main.ids
  tags               = local.tags
  alb_arn            = module.alb.arn
  parameters_key_arn = aws_kms_key.grafana-parameters.arn
  cluster_id         = aws_ecs_cluster.cluster.id
  alb_dns_name       = module.alb.dns_name
  route53_zone       = local.route53_zone
}

# ----------------------------------------
# ALB Listener
# ----------------------------------------
resource "aws_lb_listener" "main" {
  load_balancer_arn = module.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = module.grafana.target_group_arn
  }
}

# ----------------------------------------
# Security Group Rules
# ----------------------------------------

resource "aws_security_group_rule" "lb_ingress" {
  type              = "ingress"
  description       = "Allow HTTP from internet"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = module.alb.security_group_id
}

resource "aws_security_group_rule" "lb_grafana_ingress_rule" {
  security_group_id        = module.grafana.service_sg_id
  description              = "Allow LB to communicate the Fargate ECS service."
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3000
  to_port                  = 3000
  source_security_group_id = module.alb.security_group_id
}

resource "aws_kms_key" "grafana-parameters" {
  description = "KMS key for encrypting parameters passed to grafana."
  tags        = local.tags
}

resource "aws_kms_alias" "key-alias" {
  name          = "alias/${local.name_prefix}-parameters"
  target_key_id = aws_kms_key.grafana-parameters.id
}

#Passwords set and storted in repo for example only (don't do it this way!)
resource "aws_ssm_parameter" "rds_username" {
  name   = "/${local.name_prefix}/rds-username"
  type   = "SecureString"
  value  = "username"
  key_id = aws_kms_key.grafana-parameters.key_id
}

resource "aws_ssm_parameter" "rds_password" {
  name   = "/${local.name_prefix}/rds-password"
  type   = "SecureString"
  value  = "notsogoodpassword"
  key_id = aws_kms_key.grafana-parameters.key_id
}

resource "aws_ssm_parameter" "admin_username" {
  name   = "/${local.name_prefix}/admin-username"
  type   = "SecureString"
  value  = "admin"
  key_id = aws_kms_key.grafana-parameters.key_id
}

resource "aws_ssm_parameter" "admin_password" {
  name   = "/${local.name_prefix}/admin-password"
  type   = "SecureString"
  value  = "anotherbadpassword"
  key_id = aws_kms_key.grafana-parameters.key_id
}

resource "aws_ssm_parameter" "github-auth-enabled" {
  name   = "/${local.name_prefix}/github-auth-enabled"
  type   = "SecureString"
  value  = "true"
  key_id = aws_kms_key.grafana-parameters.key_id
}

resource "aws_ssm_parameter" "github-client-id" {
  name   = "/${local.name_prefix}/github-client-id"
  type   = "SecureString"
  value  = "<id-from-github>"
  key_id = aws_kms_key.grafana-parameters.key_id
}

resource "aws_ssm_parameter" "github-client-secret" {
  name   = "/${local.name_prefix}/github-client-secret"
  type   = "SecureString"
  value  = "<secret-from-github>"
  key_id = aws_kms_key.grafana-parameters.key_id
}

resource "aws_ssm_parameter" "github-organizations" {
  name   = "/${local.name_prefix}/github-organizations"
  type   = "SecureString"
  value  = "<github-organization>"
  key_id = aws_kms_key.grafana-parameters.key_id
}

