docker kill nginx-div    
docker rm nginx-div
docker run --name nginx-div -p 9090:9090 -p 9091:9091 -d dockerhub.dap.local/nginx-diy:v1.67
