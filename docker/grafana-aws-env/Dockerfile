FROM grafana/grafana:7.5.3
USER root
RUN curl -L https://github.com/telia-oss/aws-env/releases/download/v1.0.2/aws-env-linux-amd64 > /usr/local/bin/aws-env && \
      echo 40b4ea70f42a7583502a319d2483d47c  /usr/local/bin/aws-env | md5sum -c && \
      chmod +x /usr/local/bin/aws-env

COPY entrypoint.sh ./
USER grafana
ENTRYPOINT ["./entrypoint.sh"]