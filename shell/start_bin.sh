#!/bin/sh
# 帮助文档
helpdoc(){
    cat <<EOF
Usage:

    $0 -a <app> 

参数说明:

    -a 要启动的服务, 列表如下:
      shenyu-admin:       shenyu-admin（网关管理）
      shenyu-bootstrap:   shenyu-bootstrap（网关服务）
      expos-admin:        expos-admin（系统管理）
      expos-workflow:     expos-workflow（工单管理）
EOF
}
# 启动容器
start()
{
  echo $APP_NAME 'is starting at port:' $PORT
  echo 'pulling image'
  docker pull $IMAGE
  echo 'starting container'
  docker run -d --name $APP_NAME -p $PORT:$PORT -e $ENV -v $VOLUME --network expos ${IMAGE}
  echo $APP_NAME 'started'
}

while getopts ":a:" opt
do
    case $opt in
        a)
        APP_INDEX=`echo $OPTARG`
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
  IMAGE=harbor.dap.local/prod/shenyu-admin:2.4.2-10
  APP_NAME=shenyu-admin
  PROFILES_ACTIVE=pre
  ENV="SPRING_PROFILES_ACTIVE="$PROFILES_ACTIVE
  VOLUME=/var/run/$APP_NAME/logs:/opt/shenyu-admin/logs
  if [ -z "$PORT" ]; then
    PORT=9095
  fi
elif [ "$APP_INDEX" = "2" -o "$APP_INDEX" = "shenyu-bootstrap" ]; then
  IMAGE=harbor.dap.local/prod/shenyu-bootstrap:2.4.2-12
  APP_NAME=shenyu-bootstrap
  PROFILES_ACTIVE=pre
  ENV="SPRING_PROFILES_ACTIVE="$PROFILES_ACTIVE
  VOLUME=/var/run/$APP_NAME/logs:/opt/shenyu-bootstrap/logs
  if [ -z "$PORT" ]; then
    PORT=9195
  fi
elif [ "$APP_INDEX" = "3" -o "$APP_INDEX" = "expos-admin" ]; then
  IMAGE=harbor.dap.local/prod/expos-admin:1.0.3-SNAPSHOT-9
  APP_NAME=expos-admin
  PROFILES_ACTIVE=pre
  ENV="envType="$PROFILES_ACTIVE
  VOLUME=/var/run/$APP_NAME/logs:/opt/expos-admin-bootstrap/logs
  if [ -z "$PORT" ]; then
    PORT=9080
  fi
elif [ "$APP_INDEX" = "4" -o "$APP_INDEX" = "expos-workflow" ]; then
  IMAGE=harbor.dap.local/prod/expos-workflow:1.0.3-SNAPSHOT-3
  APP_NAME=expos-workflow
  PROFILES_ACTIVE=pre
  ENV="envType="$PROFILES_ACTIVE
  VOLUME=/var/run/$APP_NAME/logs:/opt/workflow-bootstrap/logs
  if [ -z "$PORT" ]; then
    PORT=8081
  fi
else
  helpdoc
  exit 1
fi

start
