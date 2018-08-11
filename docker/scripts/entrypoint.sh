#!/bin/bash
if [ -z "$AWS_REGION" ]; then
    export AWS_REGION="eu-west-1"
fi
set -ex
/usr/local/bin/aws-env exec ./run.sh