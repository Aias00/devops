#!/bin/sh
#================================================================
# HEADER
#================================================================
#    Filename         send-ding.sh
#    Revision         0.0.1
#    Date             2020/06/08
#    Author           jiangliheng
#    Email            jiang_liheng@163.com
#    Website          https://jiangliheng.github.io/
#    Description      发送钉钉消息
#    Copyright        Copyright (c) jiangliheng
#    License          GNU General Public License
#
#================================================================
#
#  Version 0.0.1 2020/06/08
#     发送钉钉消息，支持 text，markdown 两种类型消息
#
#================================================================
#%名称(NAME)
#%       ${SCRIPT_NAME} - 发送钉钉消息
#%
#%概要(SYNOPSIS)
#%       sh ${SCRIPT_NAME} [options] <value> ...
#%
#%描述(DESCRIPTION)
#%       发送钉钉消息
#%
#%选项(OPTIONS)
#%     * -a <value>                 钉钉机器人 Webhook 地址的 access_token
#%     * -t <value>                 消息类型：text，markdown
#%     & -T <value>                 title，首屏会话透出的展示内容；消息类型（-t）为：markdown 时
#%     * -c <value>                 消息内容，content或者text
#%     & -m <value>                 被@人的手机号（在 content 里添加@人的手机号），多个参数用逗号隔开；如：138xxxx6666，182xxxx8888；与是否@所有人（-A）互斥，仅能选择一种方式
#%     & -A                         是否@所有人，即 isAtAll 参数设置为 ture；与被@人手机号（-m）互斥，仅能选择一种方式
#%       -v, --version              版本信息
#%       --help                     帮助信息
#%
#%     * 表示必输，& 表示条件必输，其余为可选
#%
#%示例(EXAMPLES)
#%
#%       1. 发送 text 消息类型，并@指定人
#%       sh ${SCRIPT_NAME} -a xxx -t text -c "我就是我, 是不一样的烟火" -m "138xxxx6666,182xxxx8888"
#%
#%       2. 发送 markdown 消息类型，并@所有人
#%       sh ${SCRIPT_NAME} -a xxx -t markdown -T "markdown 测试标题" -c "# 我就是我, 是不一样的烟火" -A
#%
#================================================================
# END_OF_HEADER
#================================================================

# header 总行数
SCRIPT_HEADSIZE=$(head -200 "${0}" |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
# 脚本名称
SCRIPT_NAME="$(basename "${0}")"
# 版本
VERSION="0.0.1"

test_url='https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fd.ifengimg.com%2Fw2560_h1440_q70%2Fimg1.ugc.ifeng.com%2Fnewugc%2F20200718%2F10%2Fwemedia%2F7b2e10e55d549a793c143b3e4fccca63c8d2016f_size333_w2560_h1440.jpg&refer=http%3A%2F%2Fd.ifengimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1625235016&t=2706f0c8b591db6a476e95661f4dfff8'

# usage
function usage() {
  head -"${SCRIPT_HEADSIZE:-99}" "${0}" \
  | grep -e "^#%" \
  | sed -e "s/^#%//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" -e "s/\${VERSION}/${VERSION}/g"
}

# 发送 ding 消息
function sendDingMessage() {
  curl -s "${1}" -H 'Content-Type: application/json' -d "${2}"
}

# 检查参数输入合法性
function checkParameters() {
  # -a，-t，-c 参数必输校验
  if [ -z "${ACCESS_TOKEN}" ] || [ -z "${MSG_TYPE}" ] || [ -z "${CONTENT}" ]
  then
    printf "Parameter [-a,-t,-c] is required!\n"
    exit 1
  fi

  # -t 为：markdown 时，检验参数 -T 必输
  if [ "X${MSG_TYPE}" = "Xmarkdown" ] && [ -z "${TITLE}" ]
  then
    printf "When [-t] is 'markdown', you must enter the parameter [-T]!\n"
    exit 1
  fi

  # -A 和 -m 互斥，仅能选择一种方式
  if [ "X${IS_AT_ALL}" = "Xtrue" ] && [ -n "${MOBILES}" ]
  then
    printf "Only one of the parameters [-A] and [-m] can be entered!\n"
    exit 1
  fi
}

# markdown 消息内容
function markdownMessage() {
  # 标题
  title=${1}
  # 消息内容
  text=${2}
  # @ 方式
  at=${3}

  # 判断是@所有人，还是指定人
  if [ -z "${at}" ]; then
    atJson=""
  elif [ "X${at}" = "Xtrue" ]; then
    atJson='"at": {
        "isAtAll": true }'
  else
    # 判断是否多个手机号
    result=$(echo "${at}" | grep ",")

    # N 个手机号
    if [ "X${result}" != "X" ]; then
      # 转换为手机号数组
      mobileArray=(${at//,/ })
      # 循环遍历数组，组织 json 格式字符串
      for mobile in "${mobileArray[@]}"
      do
         mobiles="${mobile}",${mobiles}
         # @ 指定人
         atMobiles="@${mobile}",${atMobiles}
      done

    # 1 个手机号
    else
      mobiles="${at}"
      # @ 指定人
      atMobiles="@${at}"
    fi

    # @ json内容
    atJson='"at": {
        "atMobiles": [
            '${mobiles/%,/}'
        ]
    }'

    # 内容信息添加 @指定人
    text="${text}\n${atMobiles/%,/}"
  fi

  message='{
       "msgtype": "markdown",
       "markdown": {
           "title":"'${title}'",
           "text": "'${text}'"},
        '${atJson}'
   }'

   echo "${message}"
}

# text 消息内容
function textMessage() {
  # 消息内容
  text=${1}
  # @ 方式
  at=${2}

  # 判断是@所有人，还是指定人
  if [ -z "${at}" ]; then
    atJson=""
  elif [ "X${at}" = "Xtrue" ]; then
    atJson='"at": {
        "isAtAll": true }'
  else
    # 判断是否多个手机号
    result=$(echo "${at}" | grep ",")

    # N 个手机号
    if [ "X${result}" != "X" ]; then
      # 转换为手机号数组
      mobileArray=(${at//,/ })
      # 循环遍历数组，组织 json 格式字符串
      for mobile in "${mobileArray[@]}"
      do
         mobiles="${mobile}",${mobiles}
         # @ 指定人
         atMobiles="@${mobile}",${atMobiles}
      done

    # 1 个手机号
    else
      mobiles="${at}"
      # @ 指定人
      atMobiles="@${at}"
    fi

    # @ json内容
    atJson='"at": {
        "atMobiles": [
            '${mobiles/%,/}'
        ]
    }'

    # 内容信息添加 @指定人
    text="${text}\n${atMobiles/%,/}"
  fi

  message='{
       "msgtype": "text",
       "text": {
           "content": "'${text}'"},
        '${atJson}'
   }'

   echo "${message}"
}

# 主方法
function main() {

  # 检查参数输入合法性
  checkParameters

  # 判断发送消息类型
  case ${MSG_TYPE} in
    markdown)
      # 判断 @ 方式
      if [ -n "${MOBILES}" ]; then
        DING_MESSAGE=$(markdownMessage "${TITLE}" "${CONTENT}" "${MOBILES}")
      elif [ -n "${IS_AT_ALL}" ]; then
        DING_MESSAGE=$(markdownMessage "${TITLE}" "${CONTENT}" "${IS_AT_ALL}")
      else
        DING_MESSAGE=$(markdownMessage "${TITLE}" "${CONTENT}")
      fi
      ;;
    text)
      if [ -n "${MOBILES}" ]; then
        DING_MESSAGE=$(textMessage "${CONTENT}" "${MOBILES}")
      elif [ -n "${IS_AT_ALL}" ]; then
        DING_MESSAGE=$(textMessage "${CONTENT}" "${IS_AT_ALL}")
      else
        DING_MESSAGE=$(textMessage "${CONTENT}")
      fi
      ;;
    *)
      printf "Unsupported message type, currently only [text, markdown] are supported!"
      exit 1
      ;;
  esac

  sendDingMessage "${DING_URL}" "${DING_MESSAGE}"
}

# 判断参数个数
if [ $# -eq 0 ];
then
  usage
  exit 1
fi

# # getopt 命令行参数
# if ! ARGS=$(getopt -o vAa:t:T:c:m: --long help,version -n "${SCRIPT_NAME}" -- "$@")
# then
#   # 无效选项，则退出
#   exit 1
# fi
# echo "$ARGS"
# # 命令行参数格式化
# eval set -- "${ARGS}"

while getopts ":a:t:c:T:c:m:A:h:help:version" opt
do
  # echo $opt
  # echo $OPTARG
  case $opt in
    a)
      # Webhook access_token
      ACCESS_TOKEN=`echo $OPTARG`
      # echo ACCESS_TOKEN=$ACCESS_TOKEN
      # 钉钉机器人 url 地址
      DING_URL="https://oapi.dingtalk.com/robot/send?access_token=${ACCESS_TOKEN}"
      # echo DING_URL=$DING_URL
      ;;

    t)
      MSG_TYPE=`echo $OPTARG`
      
      ;;

    T)
      TITLE=`echo $OPTARG`
      
      ;;

    c)
      CONTENT=`echo $OPTARG`
      
      ;;

    m)
      MOBILES=`echo $OPTARG`
      
      ;;

    A)
      IS_AT_ALL=true
      echo IS_AT_ALL=$IS_AT_ALL
      ;;

    version)
      printf "%s version %s\n" "${SCRIPT_NAME}" "${VERSION}"
      exit 1
      ;;

    help)
      usage
      exit 1
      ;;

    # --)
    #   shift
    #   break
    #   ;;

    # *)
    #   printf "%s is not an option!" "$1"
    #   exit 1
    #   ;;

  esac
done

main
