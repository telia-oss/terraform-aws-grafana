FROM grafana/grafana:5.2.2

# Build Metadata
ARG BUILD_DATE
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG AWS_ENV_VERSION="v0.3.0"
ARG AWS_ENV_URL="https://github.com/telia-oss/aws-env/releases/download/$AWS_ENV_VERSION/aws-env-linux-amd64"

# Environemnt variables
ENV AWS_ENV_VERSION=${AWS_ENV_VERSION}
ENV AWS_ENV_URL=${AWS_ENV_URL}

# Metadata
LABEL maintainer="oss@telia.io" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="grafana-aws-env" \
      org.label-schema.description="This image extends the standard grafana docker image with our tool for securely handling secrets in environment variables on AWS. Supports KMS, SSM Parameter store and secrets manager. Inspired by ssm-env." \
      org.label-schema.url="https://telia-oss-github.io" \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vendor="Telia Company" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -qq -y \
      tzdata \
      tzdata \ 
      openssl \
      ca-certificates && \
      apt-get autoremove -y && \
      rm -rf /var/lib/apt/lists/*

RUN curl -L $AWS_ENV_URL > /usr/local/bin/aws-env \
      && chmod +x /usr/local/bin/aws-env \
      && chown -R grafana:grafana usr/local/bin/aws-env

COPY ./scripts/entrypoint.sh ./

USER grafana
ENTRYPOINT ["./entrypoint.sh"]