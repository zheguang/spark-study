#!/bin/bash

ACTION=$1

#$HADOOP_PREFIX/bin/hdfs namenode -format
$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs $ACTION namenode
$HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs $ACTION datanode
