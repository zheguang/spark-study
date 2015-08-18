#!/bin/bash
set -e

spark_study=$(readlink -f `dirname ${BASH_SOURCE[0]}`/../../..)
source $spark_study/scripts/common.sh
source $spark_study/scripts/bench-common.sh
BENCH_PAGERANK=$spark_study/study/bench/pagerank

dataDir=/data1/devel/research/pm-graph-data/datasets/native
declare -A dataFiles
dataFiles=(["native"]=$dataDir/Graph_S24_E16.graph_no_self_loops.1_0.gtgraph ["elist"]=$dataDir/Graph_S24_E16.graph_no_self_loops.1_0.gtgraph.edgelist)

function bench_cc {
  echo "[info] start bench cc."
  . /opt/intel/bin/compilervars.sh intel64 
  local srcDir=$PROJECT/study/src/main/cc/pagerank_single_node
  local result=$BENCH_PAGERANK/pagerank_c.result

  (cd $srcDir && make clean && make)

  numactl --interleave=all $srcDir/pagerank.out -c -f ${dataFiles["native"]} -p 8 > $result

  echo "[info] $(grep "Time/" $result)" #| awk '{print $3 " seconds/iteration";}'
  echo "[info] end bench cc."
}

function bench_graphx {
  echo "[info] assemble"
  (cd $PROJECT/study && sbt assembly)
  echo "[info] start bench graphx."
  local name=bench-GraphxPageRank
  local class=edu.brown.cs.sparkstudy.GraphxPageRank
  local jar=$PROJECT/study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  local iters=13
  local args="file://${dataFiles["elist"]} $iters"
  local result=$BENCH_PAGERANK/pagerank_graphx.result

  /usr/local/spark/bin/spark-submit --name $name --class $class $jar $args > $result
  echo "[info] $(grep "time" $result)"
  echo "[info] done bench graphx."
}

bench_cc
bench_graphx
