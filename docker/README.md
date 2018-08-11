# grafana-aws-env

[![Badge for Container Image](https://images.microbadger.com/badges/image/teliaoss/grafana-aws-env.svg)]
[![Docker Pulls](https://img.shields.io/docker/pulls/teliaoss/granfa-aws-env.svg)](https://hub.docker.com/r/teliaoss/grafana-aws-env/)

Image available from:

* [**Docker Hub**](https://hub.docker.com/r/teliaoss/grafana-aws-env.svg))

## Background

This image extends the offical grafana docker image [grafana](https://github.com/grafana/grafana-docker) with our tool for securely handling secrets in environment variables on AWS. Supports KMS, SSM Parameter store and secrets manager. Inspired by ssm-env.

The aws-env tool will loop through the environment and exchange any variables prefixed with sm://, ssm:// and kms:// with their secret value from Secrets manager.

## Instructions

### Pulling the image

From Docker Hub:

```shell
docker pull teliaoss/grafana-aws-env:latest
```

### Running grafana-aws-env

See guides and instructions for the grafana container at [grafana/grafana](https://github.com/grafana/grafana)

### Configuration

Please find more information at [aws-env](https://github.com/telia-oss/aws-env/)