#!/bin/bash
set -e

spark_study=$(readlink -f `dirname ${BASH_SOURCE[0]}`/../../..)
source $spark_study/scripts/common.sh
source $spark_study/scripts/bench-common.sh
BENCH_CFSGD=$spark_study/study/bench/cfsgd
study=$spark_study/study

declare -A dataFiles
dataFiles=(["actual"]=/data/devel/research/sam/Rating_S20.train ["test"]=$study/src/main/cc/ratings_u10_v9.dat)
mode="test"

latent=20

#nusers=996994
#nmovies=20972
#nratings=248944185
#nthreads=8

nusers=1024
nmovies=512
nratings=524288
nthreads=4

args="$latent ${dataFiles[$mode]} $nusers $nmovies $nratings $nthreads"

jar=$study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar

function jvm_compile {
  logInfo "jvm compile"
  (cd $study && sbt assembly)
}

function bench_scala {
  logInfo "bench scala"
  class=edu.brown.cs.sparkstudy.ScalaSgd
  scala -cp $jar $class none $args > $BENCH_CFSGD/sgd_scala.result
  scala -cp $jar $class dotptime $args >$BENCH_CFSGD/sgd_scala_dotptime.result

  class=edu.brown.cs.sparkstudy.BreezeSgd
  scala -cp $jar $class none $args > $BENCH_CFSGD/sgd_breeze.result
  scala -cp $jar $class dotptime $args >$BENCH_CFSGD/sgd_breeze_dotptime.result
}

function bench_java {
  logInfo "bench java"
  class=com.intel.sparkstudy.matrix.JavaSgdSingleNodeTiles
  java $JAVA_OPTS -cp $jar $class none java $args > $BENCH_CFSGD/sgd_java.result
  java $JAVA_OPTS -cp $jar $class dotptime java $args > $BENCH_CFSGD/sgd_java_dotptime.result

  java $JAVA_OPTS -cp $jar $class none blas $args > $BENCH_CFSGD/sgd_blas.result
  java $JAVA_OPTS -cp $jar $class dotptime blas $args > $BENCH_CFSGD/sgd_blas_dotptime.result
}

function bench_spark {
  logInfo "bench spark"
  name=bench-SparkSgdIndexed
  class=edu.brown.cs.sparkstudy.SparkSgdIndexed
  /usr/local/spark/bin/spark-submit --name $name --class $class $jar none $args 1> $BENCH_CFSGD/sgd_spark.result 2>/tmp/samrun

  name=bench-SparkSgdIndexedDotptime
  class=edu.brown.cs.sparkstudy.SparkSgdIndexed
  /usr/local/spark/bin/spark-submit --name $name --class $class $jar dotptime $args 1> $BENCH_CFSGD/sgd_spark.result 2>/tmp/samrun

  name=bench-MllibSgd
  class=edu.brown.cs.sparkstudy.MllibSgd
  /usr/local/spark/bin/spark-submit --name $name --class $class $jar $args 1> $BENCH_CFSGD/sgd_mllib.result 2>/tmp/samrun
}

jvm_compile

#bench_spark

old_java_opts=$JAVA_OPTS
java_opts_=$(get_java_opts)
export JAVA_OPTS=$java_opts_
logInfo "set java opts=$JAVA_OPTS"
bench_scala
bench_java
export JAVA_OPTS=$old_java_opts
logInfo "restore java opts=$JAVA_OPTS"

logInfo "done"
