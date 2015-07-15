#!/bin/bash

set -e

resources=$(dirname $0)/../resources


tar xzf $resources/spark-1.4.0-SNAPSHOT-bin-hadoop-2.4.tgz -C /tmp/

declare -A artIds

# space sensitive
artIds=(
  ["spark-1.4.0-SNAPSHOT-yarn-shuffle.jar"]="spark"
  ["spark-assembly-1.4.0-SNAPSHOT-hadoop2.4.0.jar"]="spark-assembly"
  ["spark-examples-1.4.0-SNAPSHOT-hadoop2.4.0.jar"]="spark-examples"
)

cd /tmp/spark-1.4.0-SNAPSHOT-bin-hadoop-2.4/lib/

for jarName in "${!artIds[@]}"; do
  artifact="-Dfile=$jarName -DgroupId=edu.brown.cs.sam -DartifactId=${artIds["$jarName"]} -Dversion=1.4.0 -Dpackaging=jar"
  mvn org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file $artifact
done
