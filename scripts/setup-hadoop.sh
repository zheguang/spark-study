#!/bin/bash
set -e

source $(dirname $0)/common.sh

function installHadoop {
  echo "install hadoop"
  (cd $HADOOP_GIT && $MAVEN package -DskipTests -Dtar -Pdist,native)
  tar -xzf $HADOOP_GIT/hadoop-dist/target/$HADOOP_ARCHIVE -C $INSTALL
  ln -s $INSTALL/${HADOOP_ARCHIVE%%.*} $INSTALL/hadoop
  assertExists $INSTALL/hadoop
}

function setupHadoop {
  echo "create hadoop runtime directories"
  mkdir $RUNTIME/hadoop
  mkdir $RUNTIME/hadoop/hadoop-datanode
  mkdir $RUNTIME/hadoop/hadoop-namenode
  mkdir $RUNTIME/hadoop/mr-history
  mkdir $RUNTIME/hadoop/mr-history/done
  mkdir $RUNTIME/hadoop/mr-history/tmp

  echo "copy hadoop configuration files"
  cp -f $RESOURCES/hadoop/* $HADOOP_CONF
}

function setupEnvVars {
  echo "creating hadoop environment variables"
  cp -f $RESOURCES/hadoop/hadoop.sh /etc/profile.d/hadoop.sh
}

function main {
  installHadoop

  setupHadoop

  setupEnvVars
}

main $@
