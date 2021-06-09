FROM grafana/grafana:7.5.3
USER root
RUN curl -L https://github.com/telia-oss/aws-env/releases/download/v1.0.2/aws-env-linux-amd64 > /usr/local/bin/aws-env && \
      echo b8b6a8bd5bd2260fbcea1c888a9711fc  /usr/local/bin/aws-env | md5sum -c && \
      chmod +x /usr/local/bin/aws-env

COPY ./docker/grafana-aws-env/7.5.3/entrypoint.sh ./
USER grafana

ENTRYPOINT ["./entrypoint.sh"]
