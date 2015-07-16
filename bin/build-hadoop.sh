#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

function buildHadoop {
  log "build hadoop"
  $LOCAL_PROJECT/third_party/spark/build/mvn clean package -DskipTests -Dtar -Pdist,native
}

function copyArchive {
  cp $LOCAL_PROJECT/third_party/hadoop/hadoop-dist/target/$HADOOP_ARCHIVE $LOCAL_PROJECT/resources/
}

(cd $LOCAL_PROJECT/third_party/hadoop && buildHadoop)
copyArchive
