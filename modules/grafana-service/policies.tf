resource "aws_iam_policy" "grafana-task-pol" {
  name = "${var.name_prefix}-task-pol"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters"
            ],
            "Resource": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.name_prefix}/*"
        }
    ]
}
EOF

}

resource "aws_iam_policy" "kmsfortaskpol" {
  name = "kms-access-for-${var.name_prefix}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": "${var.parameters_key_arn}"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "stsfortaskpol" {
  name = "sts-access-for-${var.name_prefix}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "NotResource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
        }
    ]
}
EOF

}

