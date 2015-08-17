#!/bin/bash
set -e

spark_study=$(readlink -f `dirname ${BASH_SOURCE[0]}`/../../..)
source $spark_study/scripts/common.sh
source $spark_study/scripts/bench-common.sh
BENCH_PAGERANK=$spark_study/study/bench/pagerank

#spark_master_url=spark://ginchi:7077
#num_executors=2
#$SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPageRank --master $spark_master_url --num-executors $num_executors $SPARK_HOME/lib/spark-examples*.jar file:///usr/local/spark/data/mllib/pagerank_data.txt

#cd /home/sam/devel/spark-study/study
#
#/usr/local/spark/bin/spark-submit --class edu.brown.cs.sparkstudy.GraphxPageRank --master spark://ginchi:7077 --num-executors 2 target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar file:///usr/local/spark/data/mllib/pagerank_data.txt 10
#

function bench_cc {
  echo "[info] start bench cc."
  . /opt/intel/bin/compilervars.sh intel64 
  srcDir=$PROJECT/study/src/main/cc/pagerank_single_node
  result=$BENCH_PAGERANK/cpagerank.result

  (cd $srcDir && make clean && make)

  #numactl --interleave=all ./PR -a -f /data1/devel/research/pm-graph-data/datasets/native/Graph_S24_E16.graph_no_self_loops.1_0.gtgraph -p 16 > out
  numactl --interleave=all $srcDir/pagerank.out -c -f /data1/devel/research/pm-graph-data/datasets/native/Graph_S20_E16.graph_no_self_loops.1_0.gtgraph -p 16 > $result

  echo "[info] $(grep "Time/" $result)" #| awk '{print $3 " seconds/iteration";}'
  echo "[info] end bench cc."
}

bench_cc
