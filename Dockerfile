FROM ubuntu:precise
MAINTAINER Shrikrishna Khose "krishna.khose@gmail.moc"

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 libpostgresql-jdbc-java

USER postgres

RUN /etc/init.d/postgresql start &&\
     psql --command "CREATE DATABASE metastore;" &&\
     psql --command "CREATE USER hive WITH PASSWORD 'hive';" && \
     psql --command "ALTER USER hive WITH SUPERUSER;" && \
     psql --command "GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;"

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf


USER root

RUN apt-get update && apt-get install  -y nano vim git chkconfig curl wget unzip tar sysv-rc-conf ntp openjdk-7-jre \
&& /etc/init.d/ntp start 

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

#Java Envrionment Variables
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 
ENV PATH $PATH:$JAVA_HOME/bin


# # Hadoop Environment Variables
ENV HDFS_USER=hdfs YARN_USER=yarn MAPRED_USER=mapred PIG_USER=pig \
	HIVE_USER=hive WEBHCAT_USER=hcat \
	HBASE_USER=hbase ZOOKEEPER_USER=zookeeper OOZIE_USER=oozie \
	ACCUMULO_USER=accumulo NAGIOS_USER=nagios FALCON_USER=falcon \
	SQOOP_USER=sqoop KNOX_USER=knox HADOOP_GROUP=hadoop \
	MAPRED_GROUP=mapred NAGIOS_GROUP=nagios 

RUN addgroup $HADOOP_GROUP \
&& addgroup $MAPRED_GROUP \
&& addgroup $NAGIOS_GROUP \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $HDFS_USER \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $ACCUMULO_USER \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $OOZIE_USER \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $ZOOKEEPER_USER \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $HBASE_USER \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $WEBHCAT_USER \ 
&& adduser --disabled-password -ingroup $HADOOP_GROUP $HIVE_USER \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $PIG_USER \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $MAPRED_USER \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $YARN_USER \
&& adduser --disabled-password -ingroup $NAGIOS_GROUP $NAGIOS_USER \ 
&& adduser --disabled-password -ingroup $HADOOP_GROUP $FALCON_USER \
&& adduser --disabled-password -ingroup $HADOOP_GROUP $SQOOP_USER\
&& adduser --disabled-password -ingroup $HADOOP_GROUP $KNOX_USER


# A common group shared by services.
ENV DFS_NAME_DIR=/hadoop/hdfs/nn
RUN mkdir -p $DFS_NAME_DIR \
&& chown -R $HDFS_USER:$HADOOP_GROUP $DFS_NAME_DIR \
&& chmod -R 755 $DFS_NAME_DIR

# Space separated list of directories where DataNodes will store the blocks.For example, /grid/hadoop/hdfs/dn /grid1/hadoop/hdfs/dn /grid2/hadoop/hdfs/dn
ENV DFS_DATA_DIR=/hadoop/hdfs/dn
RUN mkdir -p $DFS_DATA_DIR \
&& chown -R $HDFS_USER:$HADOOP_GROUP $DFS_DATA_DIR \
&& chmod -R 755 $DFS_DATA_DIR

# Space separated list of directories where SecondaryNameNode will store checkpoint image. For example, /grid/hadoop/hdfs/snn /grid1/hadoop/hdfs/snn /grid2/hadoop/hdfs/snn
ENV FS_CHECKPOINT_DIR=/hadoop/hdfs/snn
RUN mkdir -p $FS_CHECKPOINT_DIR \
&& chown -R $HDFS_USER:$HADOOP_GROUP $FS_CHECKPOINT_DIR \
&& chmod -R 755 $FS_CHECKPOINT_DIR

# Directory to store the HDFS logs.
ENV HDFS_LOG_DIR=/var/log/hadoop/hdfs
RUN mkdir -p $HDFS_LOG_DIR \
&&	chown -R $HDFS_USER:$HADOOP_GROUP $HDFS_LOG_DIR \
&&	chmod -R 755 $HDFS_LOG_DIR

# Directory to store the HDFS process ID.
ENV HDFS_PID_DIR /var/run/hadoop/hdfs
RUN mkdir -p $HDFS_PID_DIR \
&& chown -R $HDFS_USER:$HADOOP_GROUP $HDFS_PID_DIR \
&& chmod -R 755 $HDFS_PID_DIR

# Directory to store the Hadoop configuration files.
ENV HADOOP_CONF_DIR /etc/hadoop/conf
RUN mkdir -p $HADOOP_CONF_DIR \
&& chown -R $HDFS_USER:$HADOOP_GROUP $HADOOP_CONF_DIR \
&& chmod -R 755 $HADOOP_CONF_DIR



# Hadoop Service - YARN 

# Space separated list of directories where YARN will store temporary data. For example, /grid/hadoop/yarn/local /grid1/hadoop/yarn/local /grid2/hadoop/yarn/local
ENV YARN_LOCAL_DIR=/hadoop/yarn/local
RUN mkdir -p $YARN_LOCAL_DIR \
&& chown -R $YARN_USER:$HADOOP_GROUP $YARN_LOCAL_DIR \
&& chmod -R 755 $YARN_LOCAL_DIR

# Directory to store the YARN logs.
ENV YARN_LOG_DIR =/var/log/hadoop/yarn
RUN mkdir -p $YARN_LOG_DIR \
&& chown -R $YARN_USER:$HADOOP_GROUP $YARN_LOG_DIR \
&& chmod -R 755 $YARN_LOG_DIR
# Space separated list of directories where YARN will store container log data. For example, /grid/hadoop/yarn/logs /grid1/hadoop/yarn/logs /grid2/hadoop/yarn/logs
ENV YARN_LOCAL_LOG_DIR /hadoop/yarn/logs
RUN mkdir -p $YARN_LOCAL_LOG_DIR \
&& chown -R $YARN_USER:$HADOOP_GROUP $YARN_LOCAL_LOG_DIR \
&& chmod -R 755 $YARN_LOCAL_LOG_DIR
# Directory to store the YARN process ID.
ENV YARN_PID_DIR /var/run/hadoop/yarn
RUN mkdir -p $YARN_PID_DIR \
&& chown -R $YARN_USER:$HADOOP_GROUP $YARN_PID_DIR \
&& chmod -R 755 $YARN_PID_DIR

# Hadoop Service - MAPREDUCE

# Directory to store the MapReduce daemon logs.
ENV MAPRED_LOG_DIR /var/log/hadoop/mapred
RUN mkdir -p $MAPRED_LOG_DIR \
&& chown -R $MAPRED_USER:$HADOOP_GROUP $MAPRED_LOG_DIR \
&& chmod -R 755 $MAPRED_LOG_DIR 
# Directory to store the mapreduce jobhistory process ID.
ENV MAPRED_PID_DIR /var/run/hadoop/mapred
RUN mkdir -p $MAPRED_PID_DIR \
&& chown -R $MAPRED_USER:$HADOOP_GROUP $MAPRED_PID_DIR \
&& chmod -R 755 $MAPRED_PID_DIR
#
# Hadoop Service - Hive

# Directory to store the Hive configuration files.
ENV HIVE_CONF_DIR /etc/hive/conf
RUN mkdir -p $HIVE_CONF_DIR \
&& chown -R $HIVE_USER:$HADOOP_GROUP $HIVE_CONF_DIR \
&& chmod -R 755 $HIVE_CONF_DIR
# Directory to store the Hive logs.
ENV HIVE_LOG_DIR /var/log/hive
RUN mkdir -p $HIVE_LOG_DIR \
&& chown -R $HIVE_USER:$HADOOP_GROUP $HIVE_LOG_DIR \
&& chmod -R 755 $HIVE_LOG_DIR
# Directory to store the Hive process ID.
ENV HIVE_PID_DIR /var/run/hive
RUN mkdir -p $HIVE_PID_DIR \
&& chown -R $HIVE_USER:$HADOOP_GROUP $HIVE_PID_DIR \
&& chmod -R 755 $HIVE_PID_DIR
#
# Hadoop Service - WebHCat (Templeton)
#

# Directory to store the WebHCat (Templeton) configuration files.
ENV WEBHCAT_CONF_DIR /etc/hcatalog/conf/webhcat
RUN mkdir -p $WEBHCAT_CONF_DIR \
&& chown -R $WEBHCAT_USER:$HADOOP_GROUP $WEBHCAT_CONF_DIR \
&& chmod -R 755 $WEBHCAT_CONF_DIR

# Directory to store the WebHCat (Templeton) logs.
ENV WEBHCAT_LOG_DIR /var/log/webhcat
RUN mkdir -p $WEBHCAT_LOG_DIR \
&& chown -R $WEBHCAT_USER:$HADOOP_GROUP $WEBHCAT_LOG_DIR \
&& chmod -R 755 $WEBHCAT_LOG_DIR
# Directory to store the WebHCat (Templeton) process ID.
ENV WEBHCAT_PID_DIR /var/run/webhcat
RUN mkdir -p $WEBHCAT_PID_DIR \
&& chown -R $WEBHCAT_USER:$HADOOP_GROUP $WEBHCAT_PID_DIR \
&& chmod -R 755 $WEBHCAT_PID_DIR
#
# Hadoop Service - HBase
#

# Directory to store the HBase configuration files.
ENV HBASE_CONF_DIR /etc/hbase/conf 
RUN mkdir -p $HBASE_CONF_DIR \
&& chmod a+x $HBASE_CONF_DIR \
&& chown -R $HBASE_USER:$HADOOP_GROUP $HBASE_CONF_DIR \
&& chmod -R 755 $HBASE_CONF_DIR
# Directory to store the HBase logs.
ENV HBASE_LOG_DIR /var/log/hbase 
RUN mkdir -p $HBASE_LOG_DIR \
&& chown -R $HBASE_USER:$HADOOP_GROUP $HBASE_LOG_DIR \
&& chmod -R 755 $HBASE_LOG_DIR 
# Directory to store the HBase logs.
ENV HBASE_PID_DIR /var/run/hbase 
RUN mkdir -p $HBASE_PID_DIR \
&& chown -R $HBASE_USER:$HADOOP_GROUP $HBASE_PID_DIR \
&& chmod -R 755 $HBASE_PID_DIR
#
# Hadoop Service - ZooKeeper
#

# Directory where ZooKeeper will store data. For example, /grid1/hadoop/zookeeper/data
ENV ZOOKEEPER_DATA_DIR /hadoop/zookeeper/data 
RUN mkdir -p $ZOOKEEPER_DATA_DIR \
&& chown -R $ZOOKEEPER_USER:$HADOOP_GROUP $ZOOKEEPER_DATA_DIR \
&& chmod -R 755 $ZOOKEEPER_DATA_DIR
# Directory to store the ZooKeeper configuration files.
ENV ZOOKEEPER_CONF_DIR /etc/zookeeper/conf 
RUN mkdir -p $ZOOKEEPER_CONF_DIR \
&& chmod a+x $ZOOKEEPER_CONF_DIR \	
&& chown -R $ZOOKEEPER_USER:$HADOOP_GROUP $ZOOKEEPER_CONF_DIR \
&& chmod -R 755 $ZOOKEEPER_CONF_DIR
# Directory to store the ZooKeeper logs.
ENV ZOOKEEPER_LOG_DIR /var/log/zookeeper 
RUN mkdir -p $ZOOKEEPER_LOG_DIR \
&& chown -R $ZOOKEEPER_USER:$HADOOP_GROUP $ZOOKEEPER_LOG_DIR \
&& chmod -R 755 $ZOOKEEPER_LOG_DIR
# Directory to store the ZooKeeper process ID.
ENV ZOOKEEPER_PID_DIR /var/run/zookeeper 
RUN mkdir -p $ZOOKEEPER_PID_DIR \
&& chown -R $ZOOKEEPER_USER:$HADOOP_GROUP $ZOOKEEPER_PID_DIR \
&& chmod -R 755 $ZOOKEEPER_PID_DIR

#
# Hadoop Service - Pig
#

# Directory to store the Pig configuration files.
ENV PIG_CONF_DIR /etc/pig/conf 
RUN mkdir -p $PIG_CONF_DIR \
&& chown -R $PIG_USER:$HADOOP_GROUP $PIG_CONF_DIR \
&& chmod -R 755 $PIG_CONF_DIR
# Directory to store the Pig logs.
ENV PIG_LOG_DIR /var/log/pig  
RUN mkdir -p $PIG_LOG_DIR \
&& chown -R $PIG_USER:$HADOOP_GROUP $PIG_LOG_DIR \
&& chmod -R 755 $PIG_LOG_DIR
# Directory to store the Pig process ID.
ENV PIG_PID_DIR /var/run/pig 
RUN mkdir -p $PIG_PID_DIR \
&& chown -R $PIG_USER:$HADOOP_GROUP $PIG_PID_DIR \
&& chmod -R 755 $PIG_PID_DIR 

#
# Hadoop Service - Oozie
#

# Directory to store the Oozie configuration files.
ENV OOZIE_CONF_DIR /etc/oozie/conf 
RUN mkdir -p $OOZIE_CONF_DIR \
&& chown -R $OOZIE_USER:$HADOOP_GROUP $OOZIE_CONF_DIR \
&& chmod -R 755 $OOZIE_CONF_DIR
# Directory to store the Oozie data.
ENV OOZIE_DATA /var/db/oozie
RUN mkdir -p $OOZIE_DATA \
&& chown -R $OOZIE_USER:$HADOOP_GROUP $OOZIE_DATA \
&& chmod -R 755 $OOZIE_DATA
# Directory to store the Oozie logs.
ENV OOZIE_LOG_DIR /var/log/oozie 
RUN mkdir -p $OOZIE_LOG_DIR \
&& chown -R $OOZIE_USER:$HADOOP_GROUP $OOZIE_LOG_DIR \
&& chmod -R 755 $OOZIE_LOG_DIR 
# Directory to store the Oozie process ID.
ENV OOZIE_PID_DIR /var/run/oozie 
RUN mkdir -p $OOZIE_PID_DIR \
&& chown -R $OOZIE_USER:$HADOOP_GROUP $OOZIE_PID_DIR \
&& chmod -R 755 $OOZIE_PID_DIR 
# Directory to store the Oozie temporary files.
ENV OOZIE_TMP_DIR /var/tmp/oozie 
RUN mkdir -p $OOZIE_TMP_DIR \
&& chown -R $OOZIE_USER:$HADOOP_GROUP $OOZIE_TMP_DIR \
&& chmod -R 755 $OOZIE_TMP_DIR
#
# Hadoop Service - Sqoop
#
ENV SQOOP_CONF_DIR /etc/sqoop/conf 
RUN mkdir -p $SQOOP_CONF_DIR \
&& chown -R $SQOOP_USER:$HADOOP_GROUP $SQOOP_CONF_DIR \
&& chmod -R 755 $SQOOP_CONF_DIR
#
# Hadoop Service - Accumulo
#
ENV ACCUMULO_CONF_DIR /etc/accumulo/conf 
RUN mkdir -p  $ACCUMULO_CONF_DIR \
&& chown -R $ACCUMULO_USER:$HADOOP_GROUP $ACCUMULO_CONF_DIR \
&& chmod -R 755 $ACCUMULO_CONF_DIR 

ENV ACCUMULO_LOG_DIR /var/log/accumulo 
RUN mkdir -p $ACCUMULO_LOG_DIR \
&& chown -R $ACCUMULO_USER:$HADOOP_GROUP $ACCUMULO_LOG_DIR \
&& chmod -R 755 $ACCUMULO_LOG_DIR


RUN wget http://public-repo-1.hortonworks.com/HDP/ubuntu12/2.x/GA/2.2.0.0/hdp.list -O /etc/apt/sources.list.d/hdp.list ; gpg --keyserver pgp.mit.edu --recv-keys B9733A7A07513CAD ; gpg -a --export 07513CAD | apt-key add -

#
# Install Hadoop and Yarn

# On all nodes
RUN apt-get update && apt-get install  -y hadoop hadoop-hdfs libhdfs0 hadoop-yarn hadoop-mapreduce hadoop-client openssl

# On all nodes Snappy
RUN apt-get install libsnappy1 libsnappy-dev

#On all nodes LZO
RUN apt-get install -y liblzo2-2 liblzo2-dev hadooplzo 

#Hadoop Configuration
COPY /configuration_files/core_hadoop/*.* $HADOOP_CONF_DIR/

#Symlink Directories with hdp-select -  symlinks directories to hdp-current and modifies paths for configuration directories. 
RUN /usr/bin/hdp-select set all 2.2.0.0-2041

#Install ZooKeeper - create and increment number on each zookeper server
RUN apt-get install -y zookeeper supervisor; usermod -s /bin/bash zookeeper; echo 1 >> $ZOOKEEPER_DATA_DIR/myid ;

#Zookeeper Configuration on each node
COPY /configuration_files/zookeeper/*.* $ZOOKEEPER_CONF_DIR/

# Hbase Configuration File on each node
COPY /configuration_files/hbase/*.* $HBASE_CONF_DIR/

#Pig Configuaration Files on each node
COPY /configuration_files/pig/*.* $PIG_CONF_DIR/

# Hive Configuration Files on each node
COPY /configuration_files/hive/*.* $HIVE_CONF_DIR/



COPY update_hadoop_config_files.sh /tmp/ 
COPY hdpsup.conf	/etc/supervisor/conf.d/
RUN chmod 755 /tmp/update_hadoop_config_files.sh


#SSH Setup from https://docs.docker.com/examples/running_ssh_service/
ENV NOTVISIBLE="in users profile"
RUN apt-get update && apt-get install -y openssh-server \
	&& mkdir /var/run/sshd \
	&& echo 'root:hadoop' | chpasswd \
	&& sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
	&& sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
	&& echo "export VISIBLE=now" >> /etc/profile 

ADD ssh_cfg /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

RUN apt-get install -y hbase phoenix pig hive-hcatalog  tez

RUN ln -s /usr/share/java/postgresql-jdbc4.jar /usr/hdp/current/hive-metastore/lib/postgresql-jdbc4.jar
RUN chmod 644 /usr/hdp/current/hive-metastore/lib/postgresql-jdbc4.jar

#Boot HDFS
COPY boothdfs.sh /tmp/boothdfs.sh
RUN chmod 755 /tmp/boothdfs.sh

# Ports

EXPOSE 22 50070 50470 8020 9000 50075 50475 50010 50020 50090 50030 8021 50060 51111 60020 60030 2888 3888 2181 50111  8050 8141 8025 8030 8088 45454 5432 10000 10001 9083 3306 8000 65000

CMD ["/usr/bin/supervisord"]


# docker build -t krishnaji/hadoop .
# docker run -it -d --name hadoop -p 22 -p 50070:50070 -p 50470:50470 -p 8020:8020 -p 9000:9000 -p 50075:50075 -p 50475:50475 -p 50010:50010 -p 50020:50020 -p 50090:50090 -p 50030:50030 -p 8021:8021 -p 50060:50060 -p 51111:51111 -p 60020:60020 -p 60030:60030 -p 2888:2888 -p 3888:3888 -p 2181:2181 -p 50111:50111 -p 8050:8050 -p 8141:8141 -p 8025:8025 -p 8030:8030 -p 8088:8088 -p 45454:45454 -p 5432:5432 -p 10000:10000 -p 10001:10001 -p 9083:9083 -p 3306:3306 -p 8000:8000 -p 65000:65000 krishnaji/hadoop 
# ./tmp/boothdfs.sh