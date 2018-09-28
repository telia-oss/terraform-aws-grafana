provider "aws" {
  version = "1.37.0"
  region  = "eu-west-1"
}

locals {
  tags = {
    terraform   = "true"
    environment = "example"
    application = "grafana"
  }
}

module "grafana-init" {
  name_prefix = "grafana-test"
  source      = "../../../modules/init"
  tags        = "${local.tags}"
}

output "parameters_key_arn" {
  value = "${module.grafana-init.parameters_key_arn}"
}
