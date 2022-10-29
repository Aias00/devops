#!/bin/sh
IMAGE=harbor.dap.local/prod/shenyu-admin:2.4.2-9
APP_NAME=shenyu-admin
PORT=9095
PROFILES_ACTIVE=pre
network=`docker network ls | grep expos`
if [[ -n $network ]]; then
echo 'network expos exist'
else
docker create network expos
echo 'created network expos'
fi
docker pull $IMAGE
running_container=`docker ps -a -q -f "name=^${APP_NAME}$" | xargs -I {} docker port {}`
stopped_container=`docker inspect ${APP_NAME} 2> /dev/null | grep ${APP_NAME} `
if [[ -n $running_container || -n $stopped_container ]]; then
echo $APP_NAME 'container exist, remove it'
docker rm -f $APP_NAME
fi
echo $APP_NAME 'new container starting'
docker run -d --name $APP_NAME -p $PORT:$PORT -e "SPRING_PROFILES_ACTIVE="$PROFILES_ACTIVE ${IMAGE} 