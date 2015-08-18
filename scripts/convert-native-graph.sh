#!/bin/bash
set -e

spark_study=$(readlink -f `dirname ${BASH_SOURCE[0]}`/..)
. $spark_study/scripts/common.sh

dataDir=/data1/devel/research/pm-graph-data/datasets/native
#fileName=Graph_S24_E16.graph_no_self_loops.1_0.gtgraph
fileName=Graph_S20_E16.graph_no_self_loops.1_0.gtgraph 
outputFileName=${fileName}.edgelist

echo "[info] start converting"
#export JAVA_OPTS="-XX:-HeapDumpOnOutOfMemoryError"
#scala -cp $PROJECT/study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar $dataDir/Graph_S20_E16.graph_no_self_loops.1_0.gtgraph $dataDir/Graph_S20_E16.graph_no_self_loops.1_0.edgelist

python $PROJECT/scripts/convert-native-graph.py $dataDir/$fileName $dataDir/$outputFileName

chown user:user $dataDir/$outputFileName

echo "[info] done converting, file at $dataDir/$outputFileName"
