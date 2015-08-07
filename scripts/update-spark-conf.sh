#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

mode="ginchi"
node="ginchi"
if [ -n "$1" ]; then
  mode=$1
fi
if [ -n "$2" ]; then
  node=$2
fi

function update {
  echo "[info] ginchi"
  cp $PROJECT/resources/spark/spark-defaults.conf.$node $SPARK_PREFIX/conf/spark-defaults.conf
  cp $PROJECT/resources/spark/spark-env.sh.$mode $SPARK_PREFIX/conf/spark-env.sh
}

echo "[info] start updating"
update
echo "[debug] check spark-defaults.conf"
cat $SPARK_PREFIX/conf/spark-defaults.conf | egrep '^[^#].+'
echo "[debug] check spark-env.sh"
cat $SPARK_PREFIX/conf/spark-env.sh | egrep '^[^#].+'
echo "[info] done updating"
