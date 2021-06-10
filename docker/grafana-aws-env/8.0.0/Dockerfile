FROM grafana/grafana:8.0.0
USER root
RUN  apk -U upgrade && apk add curl && \ 
      curl -L https://github.com/telia-oss/aws-env/releases/download/v1.1.0/aws-env-1.1.0-linux-amd64.tar.gz | tar -xz  -C /usr/local/bin/ && \
      echo "30b5aca5f2f71f0633e5b3012bfc3a26  /usr/local/bin/aws-env" | md5sum -c && \
      chmod +x /usr/local/bin/aws-env

COPY ./docker/grafana-aws-env/8.0.0/entrypoint.sh ./
USER grafana
ENTRYPOINT ["./entrypoint.sh"]
