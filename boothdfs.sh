#!/bin/bash
echo "#Start Postgresql"
su -l postgres -c "/etc/init.d/postgresql start"

echo "#Zookeeper Server"
su -l zookeeper -c "/usr/hdp/current/zookeeper-server/bin/zkServer.sh start"

echo "#Format namenode,start namenode, datanode"
su -l hdfs -c 'hdfs namenode -format'
su -l hdfs -c '/usr/hdp/current/hadoop-client/sbin/hadoop-daemon.sh --config /etc/hadoop/conf start namenode'
su -l hdfs -c '/usr/hdp/current/hadoop-client/sbin/hadoop-daemon.sh --config /etc/hadoop/conf start datanode'

echo "#Configure YARN and MapReduce"
su -l hdfs -c 'hdfs dfs -mkdir -p /hdp/apps/2.2.0.0-2041/mapreduce' 
su -l hdfs -c 'hdfs dfs -put /usr/hdp/2.2.0.0-2041/hadoop/mapreduce.tar.gz /hdp/apps/2.2.0.0-2041/mapreduce/' 
su -l hdfs -c 'hdfs dfs -chown -R hdfs:hadoop /hdp' 
su -l hdfs -c 'hdfs dfs -chmod -R 555 /hdp/apps/2.2.0.0-2041/mapreduce' 

echo "#Start ResourceManager & nodemanager"
su -l yarn -c '/usr/hdp/current/hadoop-yarn-client/sbin/yarn-daemon.sh --config /etc/hadoop/conf start resourcemanager'
su -l yarn -c '/usr/hdp/current/hadoop-yarn-client/sbin/yarn-daemon.sh --config /etc/hadoop/conf start nodemanager'

echo "#Start MapReduce JobHistory Server"
#Change permissions on the container-executor file.
chown -R root:hadoop /usr/hdp/current/hadoop-yarn-client/bin/container-executor
chmod -R 650 /usr/hdp/current/hadoop-yarn-client/bin/container-executor
#set up directories on HDFS
su -l hdfs -c 'hdfs dfs -mkdir -p /mr-history/tmp' 
su -l hdfs -c 'hdfs dfs -chmod -R 1777 /mr-history/tmp' 
su -l hdfs -c 'hdfs dfs -mkdir -p /mr-history/done' 
su -l hdfs -c 'hdfs dfs -chmod -R 1777 /mr-history/done'
su -l hdfs -c 'hdfs dfs -chown -R mapred:hdfs /mr-history'
su -l hdfs -c 'hdfs dfs -mkdir -p /app-logs'
su -l hdfs -c 'hdfs dfs -chmod -R 1777 /app-logs'
su -l hdfs -c 'hdfs dfs -chown yarn /app-logs'	

echo "#Start HistoryServer"
su -l yarn -c '/usr/hdp/current/hadoop-mapreduce-historyserver/sbin/mr-jobhistory-daemon.sh --config /etc/hadoop/conf start historyserver'

echo "#Start Hbase and Regionserver"
su -l hbase -c '/usr/hdp/current/hbase-master/bin/hbase-daemon.sh start master'
sleep 25
su -l hbase -c '/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver'

echo "#Start Thrift & Rest"
su -l hbase -c '/usr/hdp/current/hbase-master/bin/hbase-daemon.sh start thrift'
su -l hbase -c '/usr/hdp/current/hbase-master/bin/hbase-daemon.sh start rest --infoport 8085'

echo "# Hive directory setup"
su -l hive -c "hdfs dfs -mkdir -p /user/hive"
su -l hive -c "hdfs dfs -chown hive:hdfs /user/hive"
su -l hive -c "hdfs dfs -mkdir -p /apps/hive/warehouse"
su -l hive -c "hdfs dfs -chown -R hive:hdfs /apps/hive" 
su -l hive -c "hdfs dfs -chmod -R 775 /apps/hive"
su -l hive -c "hdfs dfs -mkdir -p /tmp/scratch"
su -l hive -c "hdfs dfs -chown -R hive:hdfs /tmp/scratch" 
su -l hive -c "hdfs dfs -chmod -R 777 /tmp/scratch"

echo "init hive Schema"
su -l -c "/usr/hdp/current/hive-metastore/bin/schematool -initSchema -dbType postgres"

echo "Waiting for Metastore"
sleep 15

echo "#Hive Metastore service"
su -l hive -c "nohup /usr/hdp/current/hive-metastore/bin/hive --service metastore>/var/log/hive/hive.out 2>/var/log/hive/hive.log &"

sleep 10

echo "#Start HiveServer2:"
su -l hive -c "/usr/hdp/current/hive-server2/bin/hiveserver2 >/var/log/hive/hiveserver2.out 2> /var/log/hive/hiveserver2.log &"



echo "#Tez Configuration"
su -l hdfs -c "hdfs dfs -mkdir -p /apps/tez"
su -l hdfs -c "hdfs dfs -copyFromLocal /usr/hdp/current/tez-client/* /apps/tez"
su -l hdfs -c "hdfs dfs -chown -R hdfs:users /apps/tez"
su -l hdfs -c "hdfs dfs -chmod 755 /apps"
su -l hdfs -c "hdfs dfs -chmod 755 /apps/tez"
su -l hdfs -c "hdfs dfs -chmod 644 /apps/tez/*.jar"

