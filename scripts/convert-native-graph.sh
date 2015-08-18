#!/bin/bash
set -e

spark_study=$(readlink -f `dirname ${BASH_SOURCE[0]}`/..)
. $spark_study/scripts/common.sh

dataDir=/data1/devel/research/pm-graph-data/datasets/native
#fileName=Graph_S24_E16.graph_no_self_loops.1_0.gtgraph
files=("$dataDir/Graph_S20_E16.graph_no_self_loops.1_0.gtgraph" "$dataDir/Graph_S24_E16.graph_no_self_loops.1_0.gtgraph")

echo "[info] start converting"
#export JAVA_OPTS="-XX:-HeapDumpOnOutOfMemoryError"
#scala -cp $PROJECT/study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar $dataDir/Graph_S20_E16.graph_no_self_loops.1_0.gtgraph $dataDir/Graph_S20_E16.graph_no_self_loops.1_0.edgelist

for inf in ${files[@]}; do
  ouf=${inf}.edgelist
  python $PROJECT/scripts/convert-native-graph.py $inf $ouf
  chown user:user $ouf
  echo "[info] converted to $ouf"
done

echo "[info] done"
