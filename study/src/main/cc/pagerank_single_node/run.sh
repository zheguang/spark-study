#!/bin/bash
set -e

. /opt/intel/bin/compilervars.sh intel64

make clean && make

#numactl --interleave=all ./PR -a -f /data1/devel/research/pm-graph-data/datasets/native/Graph_S24_E16.graph_no_self_loops.1_0.gtgraph -p 16 > out
numactl --interleave=all ./pagerank.out -c -f /data1/devel/research/pm-graph-data/datasets/native/Graph_S20_E16.graph_no_self_loops.1_0.gtgraph -p 16 > cpagerank.result

grep "Time/" cpagerank.result | awk '{print $3 " seconds/iteration";}'

echo "[info] done."
