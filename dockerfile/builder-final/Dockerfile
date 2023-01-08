FROM harbor.dap.local/kubesphereio/builder-nodejs16-python-pnpm:v1

ENV NVM_VERSION v0.35.3
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION v14.18.2
ENV NODE16_VERSION 16.15.0

RUN mkdir $NVM_DIR

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh | bash

ENV NODE_PATH $NVM_DIR/$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

RUN echo "source $NVM_DIR/nvm.sh && \
  nvm install $NODE_VERSION && \
  nvm install $NODE16_VERSION && \
  nvm alias default $NODE_VERSION && \
  nvm use default" | bash