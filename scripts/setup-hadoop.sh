#!/bin/bash
set -e

source /vagrant/scripts/common.sh

SLAVE_START_=0
SLAVE_END_=0

function parseArgs {
  while getopts ":s::e:" opt; do
    case $opt in
      s)
        SLAVE_START_=$OPTARG
        ;;
      e)
        SLAVE_END_=$OPTARG
        ;;
      \?)
        echo "Invalid option $OPTARG" >&2
        ;;
      :)
        echo "Missing argument for $OPTARG" >&2
        ;;
    esac
  done
}

function installHadoop {
  log "install hadoop"
  #(cd $HADOOP_GIT && $MAVEN clean package -DskipTests -Dtar -Pdist,native)
  assertExists $RESOURCES/$HADOOP_ARCHIVE
  tar -xzf $RESOURCES/$HADOOP_ARCHIVE -C $INSTALL
  ln -s $INSTALL/${HADOOP_ARCHIVE%.*.*} $INSTALL/hadoop
  assertExists $INSTALL/hadoop
}

function setupHadoop {
  log "create hadoop runtime directories"
  mkdir $RUNTIME/hadoop
  mkdir $RUNTIME/hadoop/hadoop-datanode
  mkdir $RUNTIME/hadoop/hadoop-namenode
  mkdir $RUNTIME/hadoop/mr-history
  mkdir $RUNTIME/hadoop/mr-history/done
  mkdir $RUNTIME/hadoop/mr-history/tmp

  log "copy hadoop configuration files"
  cp -f $RESOURCES/hadoop/* $HADOOP_CONF

  log "populate hadoop slaves file"
  for i in $(seq $SLAVE_START_ $SLAVE_END_); do
    echo "node$i" >> $HADOOP_CONF/slaves
  done
}

function setupEnvVars {
  log "creating hadoop environment variables"
  cp -f $RESOURCES/hadoop/hadoop.sh /etc/profile.d/hadoop.sh
}

function main {
  parseArgs $@

  installHadoop
  setupHadoop
  setupEnvVars
}

main $@
