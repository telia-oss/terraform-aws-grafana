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

module "grafana" {
  source               = "../../"
  certificate_arn      = "arn:aws:acm:eu-west-1:111122223333:certificate/12345678-1234-1234-1234-1234567890ab"
  name_prefix          = "grafana-test"
  parameters_key_arn   = "arn:aws:kms:eu-west-1:111122223333:key/12345678-1234-1234-1234-1234567890ab"
  private_subnet_count = 2
  route53_zone         = "example.com."
  tags                 = local.tags
}

output "grafana_URL" {
  value = module.grafana.url
}

