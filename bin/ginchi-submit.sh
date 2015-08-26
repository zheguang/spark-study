#!/bin/bash
set -e

source `dirname $0`/../scripts/common.sh

name=SparkExp
class=edu.brown.cs.sparkstudy.SparkExp
jar=$PROJECT/study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar

(cd $PROJECT/study && sbt assembly)

logInfo "start"
spark-submit --name $name --class $class $jar
logInfo "done"
