output "parameters_key_arn" {
  description = "The arn of the key used to encrypt the parameters"
  value       = "${aws_kms_key.grafana_parameters.arn}"
}
