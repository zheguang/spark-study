#!/bin/bash

set -e

source $(dirname $0)/../scripts/common.sh

resources=$(dirname $0)/../resources

assertExists $resources/$SPARK_ARCHIVE
tar xzf $resources/$SPARK_ARCHIVE -C /tmp/

declare -A artIds

# space sensitive
artIds=(
  ["spark-${SPARK_VER}.${SPARK_VER_MINOR}-SNAPSHOT-yarn-shuffle.jar"]="spark"
  ["spark-assembly-${SPARK_VER}.${SPARK_VER_MINOR}-SNAPSHOT-hadoop2.4.0.jar"]="spark-assembly"
  ["spark-examples-${SPARK_VER}.${SPARK_VER_MINOR}-SNAPSHOT-hadoop2.4.0.jar"]="spark-examples"
)

cd /tmp/${SPARK_ARCHIVE%.*}/lib/

for jarName in "${!artIds[@]}"; do
  artifact="-Dfile=$jarName -DgroupId=edu.brown.cs.sam -DartifactId=${artIds["$jarName"]} -Dversion=${SPARK_VER} -Dpackaging=jar"
  mvn org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file $artifact
done
