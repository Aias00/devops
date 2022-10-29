#!/bin/sh
IMAGE=harbor.dap.local/prod/expos-admin:1.0.3-SNAPSHOT-6
APP_NAME=expos-admin
PORT=9080
PROFILES_ACTIVE=pre
createNetwork()
{
network=`docker network ls | grep expos`
if [[ -n $network ]]; then
echo 'network expos exist'
else
docker network create expos
echo 'created network expos'
fi
}

removeExistContainer()
{
running_container=`docker ps -a -q -f "name=^${APP_NAME}$" | xargs -I {} docker port {}`
stopped_container=`docker inspect ${APP_NAME} 2> /dev/null | grep ${APP_NAME} `
if [[ -n $running_container || -n $stopped_container ]]; then
echo $APP_NAME 'container exist, remove it'
docker rm -f $APP_NAME
fi
}
start()
{
echo $APP_NAME 'starting'
docker pull $IMAGE
docker run -d --name $APP_NAME -p $PORT:$PORT -e "envType="$PROFILES_ACTIVE --network expos ${IMAGE}
}

removeExistContainer
createNetwork
start