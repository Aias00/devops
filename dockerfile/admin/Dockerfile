FROM harbor.dap.local/library/openjdk:8-jre-alpine
ADD target/expos-admin-bootstrap*.tar.gz /opt
COPY entrypoint.sh /opt/expos-admin-bootstrap/entrypoint.sh
RUN chmod +x /opt/expos-admin-bootstrap/entrypoint.sh
WORKDIR /opt/expos-admin-bootstrap
EXPOSE 9080
ARG envType=local
ENV envType ${envType}
ENTRYPOINT ["/bin/sh", "entrypoint.sh","${envType}"]