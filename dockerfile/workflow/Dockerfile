FROM harbor.dap.local/library/jdk:1.8
ADD target/workflow-bootstrap*.tar.gz /opt
COPY entrypoint.sh /opt/workflow-bootstrap/entrypoint.sh
RUN chmod +x /opt/workflow-bootstrap/entrypoint.sh
WORKDIR /opt/workflow-bootstrap
EXPOSE 8081
ARG envType=local
ENV envType ${envType}
ENTRYPOINT ["/bin/sh", "entrypoint.sh","${envType}"]