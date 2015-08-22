#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

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

function installSpark {
  logInfo "install spark"
  #./make-distribution.sh --skip-java-test --name hadoop-$HADOOP_VER_MAJOR --tgz -Phadoop-$HADOOP_VER_MAJOR -Pyarn
  assertExists $RESOURCES/$SPARK_ARCHIVE
  tar -xzf $RESOURCES/$SPARK_ARCHIVE -C $INSTALL
  ln -s $INSTALL/${SPARK_ARCHIVE%.*} $INSTALL/spark
  assertExists $INSTALL/spark
}

function setupSpark {
  logInfo "set up spark"
  cp -f $RESOURCES/spark/slaves $SPARK_CONF
  cp -f $RESOURCES/spark/spark-env.sh $SPARK_CONF
  cp -f $RESOURCES/spark/spark-defaults.conf $SPARK_CONF

  mkdir -p $RUNTIME/spark
  mkdir -p $RUNTIME/spark/eventLog
}

function setupEnvVars {
  logInfo "set up spark environment variables"
  cp -f $RESOURCES/spark/spark.sh /etc/profile.d/spark.sh

  logInfo "populate spark slaves file"
  for i in $(seq $SLAVE_START_ $SLAVE_END_); do
    echo "node$i" >> $SPARK_CONF/slaves
  done
}

function main {
  parseArgs $@

  installSpark

  setupSpark

  setupEnvVars

  /bin/bash $PROJECT/scripts/update-spark-conf.sh ginchi
}

main $@
