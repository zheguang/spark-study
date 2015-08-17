#!/bin/bash
set -e

LOCAL_PROJECT=$(readlink -f `dirname ${BASH_SOURCE[0]}`/..)
if [ -d /vagrant ]; then
  PROJECT=/vagrant
else
  PROJECT=$LOCAL_PROJECT
fi
RESOURCES=$PROJECT/resources

INSTALL=/usr/local
RUNTIME=/var

function scalaVersion {
  verStr=$(/usr/local/scala/bin/scala -version 2>&1)
  echo $verStr | awk -F' ' '{print $5}'
}

SCALA_VER=$(scalaVersion)
SCALA_VER_MAJOR=${SCALA_VER%.*}

PROTOBUF_GIT=$PROJECT/third_party/protobuf
PROTOBUF_VER=2.5.0
PROTOBUF_ARCHIVE=protobuf-$PROTOBUF_VER.tar

HADOOP_GIT=$PROJECT/third_party/hadoop
HADOOP_VER_MAJOR=2.4
HADOOP_VER_MINOR=1
HADOOP_VER=${HADOOP_VER_MAJOR}.${HADOOP_VER_MINOR}
HADOOP_ARCHIVE=hadoop-${HADOOP_VER}.tar.gz
HADOOP_PREFIX=$INSTALL/hadoop
HADOOP_CONF=$HADOOP_PREFIX/etc/hadoop

SPARK_GIT=$PROJECT/third_party/spark
SPARK_VER=1.4
SPARK_VER_MINOR=2
SPARK_ARCHIVE=spark-${SPARK_VER}.$SPARK_VER_MINOR-SNAPSHOT-bin-hadoop-${HADOOP_VER_MAJOR}-scala-${SCALA_VER_MAJOR}.tgz
SPARK_PREFIX=$INSTALL/spark
SPARK_CONF=$SPARK_PREFIX/conf

MAVEN=$SPARK_GIT/build/mvn
MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

function assertExists {
  if [ -e $1 ]; then
    return 0
  else
    echo "[ERROR] file does not exist: $1"
    return 1
  fi
}

function logInfo {
  echo "[info] $@"
}

function logError {
  echo "[error] $@"
}
