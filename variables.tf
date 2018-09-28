variable "certificate_arn" {
  description = "The arn of the SSL certificate to be used"
}

variable "name_prefix" {
  description = "Typically the name of the application. This value is used as a prefix to the name of most resources created including the public URL"
}

variable "parameters_key_arn" {
  description = "The arn of the kms key used to encrypt the application parameters stored in SSM"
}

variable "private_subnet_count" {
  description = "The number of private subnets to be created in the VPC - typically this is set to the number of availability zones in the region selected"
}

variable "route53_zone" {
  description = "The route 53 zone into which this is deployed"
}

variable "tags" {
  description = "A list of tags that will be applied to resources created that support tagging"
  type        = "map"
}
