#!/bin/bash
set -e

source $(dirname $0)/../scripts/common.sh

function buildHadoop {
  log "build hadoop"
  $LOCAL_PROJECT/third_party/spark/build/mvn clean package -DskipTests -Dtar -Pdist,native
}

function copyArchive {
  cp $LOCAL_PROJECT/third_party/hadoop/hadoop-dist/target/$HADOOP_ARCHIVE $LOCAL_PROJECT/resources/
}

(cd $LOCAL_PROJECT/third_party/hadoop && buildHadoop)
copyArchive
