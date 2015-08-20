#!/bin/bash
set -e

spark_study=$(readlink -f `dirname ${BASH_SOURCE[0]}`/../../..)
source $spark_study/scripts/common.sh
source $spark_study/scripts/bench-common.sh
BENCH_PAGERANK=$spark_study/study/bench/pagerank

dataDir=/data1/devel/research/pm-graph-data/datasets/native
declare -A dataFiles

bigFile=Graph_S24_E16.graph_no_self_loops.1_0.gtgraph
smallFile=Graph_S20_E16.graph_no_self_loops.1_0.gtgraph

dataFiles=(["native"]=$dataDir/$bigFile ["elist"]=$dataDir/${bigFile}.edgelist)

numThreads=8

function bench_cc {
  echo "[info] start bench cc."
  . /opt/intel/bin/compilervars.sh intel64 
  local srcDir=$PROJECT/study/src/main/cc/pagerank_single_node
  local result=$BENCH_PAGERANK/pagerank_c.result

  (cd $srcDir && make clean && make)
  echo "[info] $(egrep "^debug" $srcDir/Makefile)"

  numactl --interleave=all $srcDir/pagerank.out -c -f ${dataFiles["native"]} -p $numThreads > $result

  echo "[info] $(grep "Time/" $result)" #| awk '{print $3 " seconds/iteration";}'
  echo "[info] end bench cc."
}

function sbt_assemble {
  echo "[info] assemble"
  (cd $PROJECT/study && sbt assembly)
}

function bench_graphx {
  echo "[info] start bench graphx."
  local name=bench-GraphxPageRank
  local class=edu.brown.cs.sparkstudy.GraphxPageRank
  local jar=$PROJECT/study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  local iters=13
  local args="file://${dataFiles["elist"]} $iters"
  local result=$BENCH_PAGERANK/pagerank_graphx.result

  /usr/local/spark/bin/spark-submit --name $name --class $class $jar $args 1>$result 2>/tmp/samrun
  echo "[info] $(grep "time" $result)"
  echo "[info] done bench graphx."
}

function bench_java {
  echo "[info] start bench java."
  local class=edu.brown.cs.sparkstudy.JavaPageRank
  local jar=$PROJECT/study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  local args="${dataFiles["native"]} $numThreads"
  local result=$BENCH_PAGERANK/pagerank_java.result

  local oldJavaOpts=$JAVA_OPTS
  export JAVA_OPTS=$(get_java_opts)
  echo "[info] set java opts=$JAVA_OPTS"

  java $JAVA_OPTS -cp $jar $class $args > $result

  export jAVA_OPTS=$oldJavaOpts
  echo "[info] restore java opts=$JAVA_OPTS"

  echo "[info] done bench java."
}

function bench_scala {
  echo "[info] start bench scala."
  local class=edu.brown.cs.sparkstudy.ScalaPageRank
  local jar=$PROJECT/study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  local args="${dataFiles["native"]} $numThreads"
  local result=$BENCH_PAGERANK/pagerank_scala.result

  local oldJavaOpts=$JAVA_OPTS
  export JAVA_OPTS=$(get_java_opts)
  echo "[info] set java opts=$JAVA_OPTS"

  scala -cp $jar $class $args > $result

  export jAVA_OPTS=$oldJavaOpts
  echo "[info] restore java opts=$JAVA_OPTS"

  echo "[info] done bench scala."
}

#bench_cc

sbt_assemble
bench_graphx
#bench_java
#bench_scala
