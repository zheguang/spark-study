#!/bin/bash
set -e

source $(dirname $0)/common.sh

function installSpark {
  echo "install spark"
  ./make-distribution.sh --skip-java-test --name hadoop-$HADOOP_VER_MAJOR --tgz -Phadoop-$HADOOP_VER_MAJOR -Pyarn
  tar -xzf $SPARK_GIT/$SPARK_ARCHIVE -C $INSTALL
  ln -s $INSTALL/${SPARK_ARCHIVE%%.*} $INSTALL/spark
  assertExists $INSTALL/spark
}

function setupSpark {
  echo "set up spark"
  cp -f $RESOURCES/spark/slaves $SPARK_CONF
  cp -f $RESOURCES/spark/spark-env.sh $SPARK_CONF
}

function setupEnvVars {
  echo "set up spark environment variables"
  cp -f $RESOURCES/spark/spark.sh /etc/profile.d/spark.sh
}

function main {
  installSpark

  setupSpark

  setupEnvVars
}

main $@
