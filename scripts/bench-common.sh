#!/bin/bash

set -e

function get_java_opts {
  dump_dir=/tmp/java
  mkdir -p $dump_dir

  # NOTE: should be the same as in resources/spark/spark-env.sh
  #initMaxYoungGen=g
  initHeap=80g
  maxHeap=80g

  #mem_opts="-server -Xmn$initMaxYoungGen -Xms$initHeap -Xmx$maxHeap -XX:+HeapDumpOnOutOfMemoryError -XX:ErrorFile=$dump_dir/hs_err_pid.log -XX:HeapDumpPath=$dump_dir"
  mem_opts="-server -Xms$initHeap -Xmx$maxHeap -XX:+HeapDumpOnOutOfMemoryError -XX:ErrorFile=$dump_dir/hs_err_pid.log -XX:HeapDumpPath=$dump_dir"
  gc_opts="-XX:+PrintFlagsFinal -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark"

  echo "$mem_opts $gc_opts"
}

