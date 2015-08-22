#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

function buildSpark {
  logInfo "build spark"
  #export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
  if [ -z $JAVA_HOME ]; then
    echo "[error] JAVA_HOME is not set."
    exit 1
  fi
  assertExists $JAVA_HOME

  (cd $PROJECT/third_party/spark && git reset --hard HEAD && $MAVEN clean)

  if [ $SCALA_VER_MAJOR = "2.10" ]; then
    ./dev/change-version-to-2.10.sh
    ./make-distribution.sh --with-tachyon --skip-java-test --name hadoop-$HADOOP_VER_MAJOR-scala-2.10 --tgz -Phadoop-$HADOOP_VER_MAJOR -Pyarn
  elif [ $SCALA_VER_MAJOR = "2.11" ]; then
    ./dev/change-version-to-2.11.sh
    #./make-distribution.sh --with-tachyon --skip-java-test --name hadoop-$HADOOP_VER_MAJOR --tgz -Phadoop-$HADOOP_VER_MAJOR -Pyarn -Dscala-2.11 
    ./make-distribution.sh --with-tachyon --skip-java-test --name hadoop-$HADOOP_VER_MAJOR-scala-2.11 --tgz -Phadoop-$HADOOP_VER_MAJOR -Pyarn -Dscala-2.11
  else
    echo "[error] unsupported scala version: $SCALA_VER_MAJOR"
    exit 1
  fi
}

function copyArchive {
  cp $LOCAL_PROJECT/third_party/spark/$SPARK_ARCHIVE $LOCAL_PROJECT/resources/
}

(cd $LOCAL_PROJECT/third_party/spark && buildSpark)
copyArchive
