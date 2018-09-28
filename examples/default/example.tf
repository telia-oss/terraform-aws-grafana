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

module "grafana" {
  source               = "../../"
  certificate_arn      = "arn:aws:acm:eu-west-1:951215386089:certificate/094ffda3-b8cc-43ef-9e6f-b10b38d81dce"
  name_prefix          = "grafana-test"
  parameters_key_arn   = "arn:aws:kms:eu-west-1:951215386089:key/b483566b-a96a-4221-9f39-5f51a2123a8d"
  private_subnet_count = "2"
  route53_zone         = "common-services-stage.telia.io."
  tags                 = "${local.tags}"
}

output "grafana_URL" {
  value = "${module.grafana.url}"
}
