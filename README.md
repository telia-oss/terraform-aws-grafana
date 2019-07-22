## Grafana

[![Build Status](https://travis-ci.com/telia-oss/terraform-aws-grafana.svg?branch=master)](https://travis-ci.com/telia-oss/terraform-aws-grafana)
![](https://img.shields.io/maintenance/yes/2019.svg)

Terraform module which creates a Grafana deployment in a Fargate ECS cluster on AWS.

## Examples

* [Simple example](/examples/default/example.tf)

## Authors

Currently maintained by [these contributors](https://github.com/telia-oss/terraform-aws-grafana/graphs/contributors).

## License

MIT License. See [LICENSE](LICENSE) for full details.

## Quick Start

### Prerequisites

This module assumes that the AWS account this is deployed to has both a Route53 zone set up and a wildcard certificate for that zone so that this can be launched behind SSL

1. Create a folder for the environment *<your_environment>*
2. Create an init subfolder in that folder
3. In the init folder Create a terraform script that uses the `modules/init` submodule and run it once (and only once) to create a key for encrypting parameters and generating random credentials
4. Note the `parameters_key_arn` output from the last step
5. Create the following SSM parameters and set them to "secure-string" and encrypt them with the key created in the previous step and replace *<name_prefix>* below with the value used for name_prefix used for the init and main module.
    - `/*<name_prefix>*/github-auth-enabled` (set to true to enable github oauth)
    - `/*<name_prefix>*/github-client-id` (obtained from github when you register oauth app)
    - `/*<name_prefix>*/github-client-secret` (obtained from github when you register oauth app)
    - `/*<name_prefix>*/github-allowed-organisations` (members from this list of github organisations can login)
    - `/*<name_prefix>*/admin-user-password` (a name for the initial admin user, note that this value is only used on first launch)
    - `/*<name_prefix>*/admin-user-name` (a password for the initial admin user, note that this value is only used on first launch)
6. In the *<your_envirnoment>* folder create a terraform script that uses the main module and use the value
 recorded in step 4 for the parameters_key_arn parameter
7. Remember to set the correct Route53 zone and web certificate ARN
8. Run terraform to deploy Grafana

## Granting Grafana Access To Cloudwatch In Other Accounts
To allow Grafana to report on metrics in a different AWS account you will need to create a role in that additional account with the `CloudWatchReadyOnlyAccess` policy attached and allow the task in the account with Grafana installed to assume that role.
The terraform script below (replace \<grafana_aws_account\> and \<name-prefix\>) when run in the additional account will grant the necessary access.

```hcl
resource "aws_iam_role" "grafana-machine-user" {
  name               = "machine-user-grafana"
  assume_role_policy = "${data.aws_iam_policy_document.grafana-machine-user.json}"
}

data "aws_iam_policy_document" "grafana-machine-user" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [
        "arn:aws:iam::<grafana_aws_account>:role/<name-prefix>-task-role",
      ]

      type = "AWS"
    }
  }
}

resource "aws_iam_role_policy_attachment" "grafana-machine-user" {
  role       = "${aws_iam_role.grafana-machine-user.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
```