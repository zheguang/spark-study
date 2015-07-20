#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
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
  ./dev/change-version-to-2.11.sh
  #./make-distribution.sh --with-tachyon --skip-java-test --name hadoop-$HADOOP_VER_MAJOR --tgz -Phadoop-$HADOOP_VER_MAJOR -Pyarn -Pscala-2.11 -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true
  ./make-distribution.sh --with-tachyon --skip-java-test --name hadoop-$HADOOP_VER_MAJOR --tgz -Phadoop-$HADOOP_VER_MAJOR -Pyarn -Dscala-2.11
}

function copyArchive {
  cp $LOCAL_PROJECT/third_party/spark/$SPARK_ARCHIVE $LOCAL_PROJECT/resources/
}

(cd $LOCAL_PROJECT/third_party/spark && buildSpark)
copyArchive
