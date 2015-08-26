#!/bin/bash

set -e

function get_java_opts {
  dump_dir=/home/user/sam/java-dump
  mkdir -p $dump_dir

  # NOTE: should be the same as in resources/spark/spark-env.sh
  #initMaxYoungGen=g
  #initHeap=200g
  #maxHeap=200g

  #mem_opts="-server -Xms$initHeap -Xmx$maxHeap -XX:+HeapDumpOnOutOfMemoryError -XX:ErrorFile=$dump_dir/hs_err_pid.log -XX:HeapDumpPath=$dump_dir"
  #mem_opts="-server -XX:+HeapDumpOnOutOfMemoryError -XX:ErrorFile=$dump_dir/hs_err_pid.log -XX:HeapDumpPath=$dump_dir"
  #gc_opts="-XX:+PrintFlagsFinal -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark -XX:+PrintAdaptiveSizePolicy -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=100"
  #gc_opts="-XX:NewSize=20g -XX:+PrintFlagsFinal -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution"

  echo "$mem_opts $gc_opts"
}

