#!/bin/bash

cd $HADOOP_CONF_DIR 
#hadoop-env.sh
sed -e "s#TODO-JDK-PATH#$JAVA_HOME#g" hadoop-env.sh > temp-hadoop-env.sh 
rm hadoop-env.sh 
cat temp-hadoop-env.sh > hadoop-env.sh 
#core-site.xml 
sed -e "s#TODO-NAMENODE-HOSTNAME:PORT#$(hostname):8020#g" core-site.xml > tmp_core-site.xml 
rm core-site.xml 
cat tmp_core-site.xml > core-site.xml 

# hdfs-site.xml 
sed -e "s#TODO-DFS-DATA-DIR#$DFS_DATA_DIR#g" \
-e "s#TODO-FS-CHECKPOINT-DIR#$FS_CHECKPOINT_DIR#g" \
-e "s#TODO-NAMENODE-HOSTNAME#$(hostname)#g"  \
-e "s#TODO-DFS-NAME-DIR#$DFS_NAME_DIR#g" \
-e "s#TODO-SECONDARYNAMENODE-HOSTNAME#$(hostname)#g" hdfs-site.xml > tmp-hdfs-site.xml 
rm hdfs-site.xml  
cat tmp-hdfs-site.xml > hdfs-site.xml 

#yarn-site.xml 
sed -e "s#TODO-ZOOKEEPER1-HOST:2181,TODO-ZOOKEEPER2-HOST:2181,TODO-ZOOKEEPER3-HOST:2181#$(hostname):2181#g" \
	-e "s#TODO-JOBHISTORYNODE-HOSTNAME#$(hostname)#g" \
	-e	"s#TODO-YARN-LOCAL-DIR#$YARN_LOCAL_DIR#g" \
	-e "s#TODO-YARN-LOCAL-LOG-DIR#$YARN_LOCAL_LOG_DIR#g" \
	-e	"s#TODO-RESOURCEMANAGERNODE-HOSTNAME#$(hostname)#g" yarn-site.xml > temp-yarn-site.xml 
rm yarn-site.xml 
cat temp-yarn-site.xml > yarn-site.xml 	

#yarn-env.sh

sed -e "s#TODO-JDK-PATH#$JAVA_HOME#g" yarn-env.sh > temp-yarn-env.sh
rm yarn-env.sh
cat temp-yarn-env.sh > yarn-env.sh
     
 #mapred-site.xml
 sed "s#TODO-JOBHISTORYNODE-HOSTNAME#$(hostname)#g" mapred-site.xml > temp-mapred-site.xml 
 rm mapred-site.xml 
 cat temp-mapred-site.xml > mapred-site.xml  

#Zookeeper Configuratoin files
cd $ZOOKEEPER_CONF_DIR 
#zoo.cfg
sed -e "s#TODO-ZOOKEEPER-DATA-DIR#$ZOOKEEPER_DATA_DIR#g" \
	-e "s#TODO-ZKSERVER-HOSTNAME#$(hostname)#g" zoo.cfg > temp-zoo.cfg 
rm zoo.cfg 
cat temp-zoo.cfg > zoo.cfg 

# zookeeper-env.sh
sed -e "s#TODO-JDK-PATH#$JAVA_HOME#g" zookeeper-env.sh > temp-zookeeper-env.sh
rm zookeeper-env.sh 
cat temp-zookeeper-env.sh > zookeeper-env.sh 

#hbase-site.xml
cd $HBASE_CONF_DIR 
sed -e "s#TODO-NAMENODE-HOST-NAME#$(hostname)#g" \
 	-e "s#TODO-ZOOKEEPER-HOST_NAME#$(hostname)#g" hbase-site.xml > temp-hbase-site.xml 
rm hbase-site.xml 
cat temp-hbase-site.xml > hbase-site.xml 
#hbase-env.sh
sed -e "s#TODO-JDK-PATH#$JAVA_HOME#g" hbase-env.sh > temp-hbase-env.sh
rm hbase-env.sh
cat temp-hbase-env.sh > hbase-env.sh

#pig-env.sh
cd $PIG_CONF_DIR
sed -e "s#TODO-JDK-PATH#$JAVA_HOME#g" pig-env.sh > temp-pig-env.sh
rm pig-env.sh
cat temp-pig-env.sh > pig-env.sh

#hive-env.sh
cd $HIVE_CONF_DIR
sed -e "s#TODO-JDK-PATH#$JAVA_HOME#g" hive-env.sh > temp-hive-env.sh
rm hive-env.sh
cat temp-hive-env.sh > hive-env.sh

#hive-site.xml
sed -e "s#localhost#$(hostname)#g" hive-site.xml > temp-hive-site.xml
rm hive-site.xml
cat temp-hive-site.xml > hive-site.xml



 


