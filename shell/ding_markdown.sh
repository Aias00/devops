#!/bin/bash
webhook='https://oapi.dingtalk.com/robot/send?access_token=c1ab2c4586148152235bffcc715bd4faeb4daa721df1ec9fafe85b99679fccb3'

NAME=$1
NUMBER=$2
PEOPLE=$3
STATUS=$4
BUILD_URL=$5
function rebot() {
  curl $webhook -H 'Content-Type: application/json' -d "
  {
    'msgtype': 'markdown',
    'markdown': {
      'title':'流水线通知',
      'text': '### 流水线通知 \n - 任务名称: ${NAME} \n - 任务编号: ${NUMBER} \n - 发起人: ${PEOPLE} \n - 执行状态: ${STATUS} \n - 查看详情: [流水线详情](${BUILD_URL}) \n'
    },
    'at':{
      'isAtAll':true
    }
  }"
}

rebot