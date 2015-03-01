# Build Image
docker build -t krishnaji/hadoop .
# Create Container
docker run -it -d --name hadoop -p 22 -p 50070:50070 -p 50470:50470 -p 8020:8020 -p 9000:9000 -p 50075:50075 -p 50475:50475 -p 50010:50010 -p 50020:50020 -p 50090:50090 -p 50030:50030 -p 8021:8021 -p 50060:50060 -p 51111:51111 -p 60020:60020 -p 60030:60030 -p 2888:2888 -p 3888:3888 -p 2181:2181 -p 50111:50111 -p 8050:8050 -p 8141:8141 -p 8025:8025 -p 8030:8030 -p 8088:8088 -p 45454:45454 -p 5432:5432 -p 10000:10000 -p 10001:10001 -p 9083:9083 -p 3306:3306 krishnaji/hadoop 
# ssh to this container. The password is "hadoop"

# Boot all hdfs services, run
./tmp/boothdfs.sh
