provider "aws" {
  region = "eu-west-1"
}

locals {
  tags = {
    terraform   = "true"
    environment = "example"
    application = "grafana"
  }
}

module "grafana_init" {
  name_prefix = "grafana-test"
  source      = "../../../modules/init"
  tags        = local.tags
}

output "parameters_key_arn" {
  value = module.grafana_init.parameters_key_arn
}
