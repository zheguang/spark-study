#!/bin/bash
set -e

spark_study=$(readlink -f `dirname ${BASH_SOURCE[0]}`/../../..)
source $spark_study/scripts/common.sh
source $spark_study/scripts/bench-common.sh
BENCH_CFSGD=$spark_study/study/bench/cfsgd
study=$spark_study/study

declare -A dataFiles
dataFiles=(["actual"]=/data/devel/research/sam/Rating_S20.train ["test"]=$study/src/main/cc/ratings_u10_v9.dat)
mode="actual"
echo "[info] bench mode: $mode"

latent=20

nusers=996994
nmovies=20972
nratings=248944185
nthreads=8

#nusers=1024
#nmovies=512
#nratings=524288
#nthreads=4

ccArgs="${dataFiles[$mode]} $nusers $nmovies $nratings $nthreads"
jArgs="$latent $ccArgs"

jar=$study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
ccBuild=$PROJECT/study/target/cc

function jvm_compile {
  logInfo "jvm compile"
  (cd $study && sbt assembly)
}

function cc_compile {
  ccSrc=$PROJECT/study/src/main/cc
  rm -rf $ccBuild && mkdir -p $ccBuild
  icpc -DLATENT=$latent -DCPP -O3 -xHost -openmp $ccSrc/sgd_single_node_tiles.cpp -o $ccBuild/sgd_cc.out -lmkl_rt
  icpc -DLATENT=$latent -DCPP -O3 -xHost -openmp $ccSrc/sgd_single_node_tiles_copyedge.cpp -o $ccBuild/sgd_cc_copyedge.out -lmkl_rt
  icpc -DLATENT=$latent -DBLAS -O3 -xHost -openmp $ccSrc/sgd_single_node_tiles_copyedge.cpp -o $ccBuild/sgd_cc_copyedge_blas.out -lmkl_rt
  icpc -DLATENT=$latent -DCPP -DDOTPTIME -O3 -xHost -openmp $ccSrc/sgd_single_node_tiles_copyedge.cpp -o $ccBuild/sgd_cc_copyedge_dotptime.out -lmkl_rt
}

function bench_cc {
  logInfo "bench cc"
  $ccBuild/sgd_cc.out $ccArgs > $BENCH_CFSGD/sgd_cc.result
  $ccBuild/sgd_cc_copyedge.out $ccArgs > $BENCH_CFSGD/sgd_cc_copyedge.result
  $ccBuild/sgd_cc_copyedge_blas.out $ccArgs > $BENCH_CFSGD/sgd_cc_copyedge_blas.result
  $ccBuild/sgd_cc_copyedge_dotptime.out $ccArgs > $BENCH_CFSGD/sgd_cc_copyedge_dotptime.result
}

function bench_scala {
  logInfo "bench scala"
  #class=edu.brown.cs.sparkstudy.ScalaSgd
  #scala -cp $jar $class none $jArgs > $BENCH_CFSGD/sgd_scala.result
  #scala -cp $jar $class dotptime $jArgs >$BENCH_CFSGD/sgd_scala_dotptime.result

  class=edu.brown.cs.sparkstudy.BreezeSgd
  scala -cp $jar $class none $jArgs > $BENCH_CFSGD/sgd_breeze.result
  scala -cp $jar $class dotptime $jArgs >$BENCH_CFSGD/sgd_breeze_dotptime.result
}

function bench_java {
  logInfo "bench java"
  class=com.intel.sparkstudy.matrix.JavaSgdSingleNodeTiles
  java $JAVA_OPTS -cp $jar $class none java $jArgs > $BENCH_CFSGD/sgd_java.result
  java $JAVA_OPTS -cp $jar $class dotptime java $jArgs > $BENCH_CFSGD/sgd_java_dotptime.result

  java $JAVA_OPTS -cp $jar $class none blas $jArgs > $BENCH_CFSGD/sgd_blas.result
  java $JAVA_OPTS -cp $jar $class dotptime blas $jArgs > $BENCH_CFSGD/sgd_blas_dotptime.result
}

function bench_spark {
  logInfo "bench spark"
  name=bench-SparkSgdIndexed
  class=edu.brown.cs.sparkstudy.SparkSgdIndexed
  /usr/local/spark/bin/spark-submit --name $name --class $class $jar none $jArgs 1> $BENCH_CFSGD/sgd_spark.result 2>/tmp/samrun

  #name=bench-SparkSgdIndexedDotptime
  #class=edu.brown.cs.sparkstudy.SparkSgdIndexed
  #/usr/local/spark/bin/spark-submit --name $name --class $class $jar dotptime $jArgs 1> $BENCH_CFSGD/sgd_spark.result 2>/tmp/samrun

  #name=bench-MllibSgd
  #class=edu.brown.cs.sparkstudy.MllibSgd
  #/usr/local/spark/bin/spark-submit --name $name --class $class $jar $jArgs 1> $BENCH_CFSGD/sgd_mllib.result 2>/tmp/samrun
}

source /opt/intel/bin/compilervars.sh intel64
cc_compile
bench_cc

#jvm_compile
#bench_spark
#
#old_java_opts=$JAVA_OPTS
#java_opts_=$(get_java_opts)
#export JAVA_OPTS=$java_opts_
#logInfo "set java opts=$JAVA_OPTS"
#bench_scala
#bench_java
#export JAVA_OPTS=$old_java_opts
#logInfo "restore java opts=$JAVA_OPTS"

logInfo "done"
