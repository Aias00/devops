#!/bin/sh
# 帮助文档
helpdoc(){
    cat <<EOF
Usage:

    $0 -a <app> -p <port> -m <image>

参数说明:

    -a 要启动的服务

      1 或者 shenyu-admin:       shenyu-admin（网关管理）
      2 或者 shenyu-bootstrap:   shenyu-bootstrap（网关服务）
      3 或者 expos-admin:        expos-admin（系统管理）
      4 或者 expos-workflow:     expos-workflow（工单管理）

    -p 容器暴露的端口号

    -m 容器镜像

EOF
}
# 创建docker网络
createNetwork()
{
  network=`docker network ls | grep expos`
if [[ -z $network ]]; then
  docker network create expos
  echo 'created network expos'
fi
}
# 移除之前的容器
removeExistContainer()
{
  running_container=`docker ps -a -q -f "name=^${APP_NAME}$" | xargs -I {} docker port {}`
  stopped_container=`docker inspect ${APP_NAME} 2> /dev/null | grep ${APP_NAME} `
if [[ -n $running_container || -n $stopped_container ]]; then
  echo $APP_NAME 'container exist, remove it'
  docker rm -f $APP_NAME
fi
}
# 启动容器
start()
{
  echo $APP_NAME 'is starting at port:' $PORT
  echo 'pulling image'
  docker pull $IMAGE
  echo 'starting container'
  docker run -d --name $APP_NAME -p $PORT:$PORT -e $ENV -v $VOLUME -v /etc/localtime:/etc/localtime --network expos ${IMAGE}
  echo $APP_NAME 'started'
}

while getopts ":a:p:" opt
do
    case $opt in
        a)
        APP_INDEX=`echo $OPTARG`
        ;;
        p)
        PORT=`echo $OPTARG`
        ;;
        m)
        IMAGE=`echo $OPTARG`
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done
if [ -z "$APP_INDEX" ];then
  helpdoc
  exit 1
elif [ "$APP_INDEX" = "1" -o "$APP_INDEX" = "shenyu-admin" ]; then
  APP_NAME=shenyu-admin
  PROFILES_ACTIVE=pre
  ENV="SPRING_PROFILES_ACTIVE="$PROFILES_ACTIVE
  VOLUME=/var/run/$APP_NAME/logs:/opt/shenyu-admin/logs
  if [ -z "$IMAGE" ]; then
    IMAGE=harbor.dap.local/prod/shenyu-admin:2.4.2-10
  fi
  if [ -z "$PORT" ]; then
    PORT=9095
  fi
elif [ "$APP_INDEX" = "2" -o "$APP_INDEX" = "shenyu-bootstrap" ]; then
  APP_NAME=shenyu-bootstrap
  PROFILES_ACTIVE=pre
  ENV="SPRING_PROFILES_ACTIVE="$PROFILES_ACTIVE
  VOLUME=/var/run/$APP_NAME/logs:/opt/shenyu-bootstrap/logs
  if [ -z "$IMAGE" ]; then
    IMAGE=harbor.dap.local/prod/shenyu-bootstrap:2.4.2-12
  fi
  if [ -z "$PORT" ]; then
    PORT=9195
  fi
elif [ "$APP_INDEX" = "3" -o "$APP_INDEX" = "expos-admin" ]; then
  APP_NAME=expos-admin
  PROFILES_ACTIVE=pre
  ENV="envType="$PROFILES_ACTIVE
  VOLUME=/var/run/$APP_NAME/logs:/opt/expos-admin-bootstrap/logs
  if [ -z "$IMAGE" ]; then
    IMAGE=harbor.dap.local/prod/expos-admin:1.0.3-SNAPSHOT-14
  fi
  if [ -z "$PORT" ]; then
    PORT=9080
  fi
elif [ "$APP_INDEX" = "4" -o "$APP_INDEX" = "expos-workflow" ]; then
  APP_NAME=expos-workflow
  PROFILES_ACTIVE=pre
  ENV="envType="$PROFILES_ACTIVE
  VOLUME=/var/run/$APP_NAME/logs:/opt/workflow-bootstrap/logs
  if [ -z "$IMAGE" ]; then
    IMAGE=harbor.dap.local/prod/expos-workflow:1.0.3-SNAPSHOT-3
  fi
  if [ -z "$PORT" ]; then
    PORT=8081
  fi
fi

removeExistContainer
createNetwork
start
