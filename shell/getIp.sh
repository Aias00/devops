local_ip=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"​`
# echo "${local_ip}"
 
# for var in ${local_ip[@]}
# do
#   echo "多网卡IP:$var"
# done
 
array=(`echo $local_ip | tr '\n' ' '` ) 
num=${#array[@]}                          #获取数组元素的个数。
# echo "IP数目：$num"

for var in ${array[@]}
do
  # echo "ip:$var"
  ip="$var"
  echo ip
  break
done
