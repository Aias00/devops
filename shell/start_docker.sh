#!/bin/sh
# 帮助文档
helpdoc(){
    cat <<EOF
Usage:

    $0 -a <app> -p <port>

参数说明:

    -a 要启动的服务

      1 或者 shenyu-admin:       shenyu-admin（网关管理）
      2 或者 shenyu-bootstrap:   shenyu-bootstrap（网关服务）
      3 或者 expos-admin:        expos-admin（系统管理）
      4 或者 expos-workflow:     expos-workflow（工单管理）

    -p 容器暴露的端口号

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
  docker run -d --name $APP_NAME -p $PORT:$PORT -e "envType="$PROFILES_ACTIVE --network expos ${IMAGE}
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
        ?)
        echo "未知参数"
        exit 1;;
    esac
done
if [ -z "$APP_INDEX" -o -z "$PORT" ];then
  helpdoc
  exit 1
elif [ "$APP_INDEX" = "1" -o "$APP_INDEX" = "shenyu-admin" ]; then
  IMAGE=harbor.dap.local/prod/shenyu-admin:2.4.2-9
  APP_NAME=shenyu-admin
  # PORT=9095
  PROFILES_ACTIVE=pre
elif [ "$APP_INDEX" = "2" -o "$APP_INDEX" = "shenyu-bootstrap" ]; then
  IMAGE=harbor.dap.local/prod/shenyu-bootstrap:2.4.2-9
  APP_NAME=shenyu-bootstrap
  # PORT=9195
  PROFILES_ACTIVE=pre
elif [ "$APP_INDEX" = "3" -o "$APP_INDEX" = "expos-admin" ]; then
  IMAGE=harbor.dap.local/prod/expos-admin:1.0.3-SNAPSHOT-6
  APP_NAME=expos-admin
  # PORT=9080
  PROFILES_ACTIVE=pre
elif [ "$APP_INDEX" = "4" -o "$APP_INDEX" = "expos-workflow" ]; then
  IMAGE=harbor.dap.local/prod/expos-workflow:1.0.3-SNAPSHOT-3
  APP_NAME=expos-workflow
  # PORT=9080
  PROFILES_ACTIVE=pre
fi

removeExistContainer
createNetwork
start
