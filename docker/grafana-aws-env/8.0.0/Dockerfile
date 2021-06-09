FROM grafana/grafana:8.0.0
USER root
RUN  apk -U upgrade && apk add curl && \ 
      curl -L https://github.com/telia-oss/aws-env/releases/download/v1.1.0/aws-env-1.1.0-linux-amd64.tar.gz > /usr/local/bin/aws-env && \
      echo b309067603e611c3d18c5114f86da89e  /usr/local/bin/aws-env | md5sum -c && \
      chmod +x /usr/local/bin/aws-env

COPY ./docker/grafana-aws-env/8.0.0/entrypoint.sh ./
USER grafana
ENTRYPOINT ["./entrypoint.sh"]

