#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

mode="ginchi"
if [ -n "$1" ]; then
  mode=$1
fi

function update {
  echo "[info] ginchi"
  cp $PROJECT/resources/spark/spark-env.sh.$mode $SPARK_PREFIX/conf/spark-env.sh
}

echo "[info] start updating"
update
. $SPARK_PREFIX/conf/spark-env.sh
echo "SPARK_WORKER_CORES=$SPARK_WORKER_CORES"
echo "SPARK_WORKER_MEMORY=$SPARK_WORKER_MEMORY"
echo "SPARK_WORKER_INSTANCES=$SPARK_WORKER_INSTANCES"
echo "[info] done updating"
