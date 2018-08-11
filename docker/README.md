# grafana-aws-env

[![Badge for Container Image](https://images.microbadger.com/badges/image/teliaoss/grafana-aws-env.svg)]
[![Docker Pulls](https://img.shields.io/docker/pulls/teliaoss/grafana-aws-env.svg)](https://hub.docker.com/r/teliaoss/grafana-aws-env/)

Image available from:

* [**Docker Hub**](https://hub.docker.com/r/teliaoss/grafana-aws-env.svg))

## Background

This image extends the official grafana docker image [grafana](https://github.com/grafana/grafana-docker) with our tool for securely handling secrets in environment variables on AWS. Supports KMS, SSM Parameter store and secrets manager. Inspired by ssm-env.

The aws-env tool will loop through the environment and exchange any variables prefixed with sm://, ssm:// and kms:// with their secret value from Secrets manager.

## Instructions

In this section we provide guidance in how to retrieve and deploy the image.

### Pulling the image

From Docker Hub:

```shell
docker pull teliaoss/grafana-aws-env:latest
```

### Running grafana-aws-env

See guides and instructions for the grafana container at [grafana/grafana](https://github.com/grafana/grafana)

For convenience we provide a [docker-compose.yml](docker/docker-compose.yml) file

```shell
mkdir data
chmod 777 data
docker-compose up -d
```

### Configuration

Please find more information at our repository for [aws-env](https://github.com/telia-oss/aws-env/) and the official documentation for Grafana.