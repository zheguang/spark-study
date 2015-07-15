#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
elif
  source $(dirname $0)/../scripts/common.sh
fi

function buildSpark {
  log "build spark"
  #export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
  if [ -z $JAVA_HOME ]; then
    echo "[error] JAVA_HOME is not set."
    exit 1
  fi
  assertExists $JAVA_HOME
  ./make-distribution.sh --skip-java-test --name hadoop-$HADOOP_VER_MAJOR --tgz -Phadoop-$HADOOP_VER_MAJOR -Pyarn
}

function copyArchive {
  cp $LOCAL_PROJECT/third_party/spark/$SPARK_ARCHIVE $LOCAL_PROJECT/resources/
}

(cd $LOCAL_PROJECT/third_party/spark && buildSpark)
copyArchive
