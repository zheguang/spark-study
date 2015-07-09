#!/bin/bash
set -e

source /opt/intel/bin/compilervars.sh intel64
export LD_LIBRARY_PATH=/opt/intel/composer_xe_2015.3.187/compiler/lib/intel64:/opt/intel/composer_xe_2015.3.187/mpirt/lib/intel64:$LD_LIBRARY_PATH
export LIBRARY_PATH=/opt/intel/composer_xe_2015.3.187/compiler/lib/intel64:/opt/intel/composer_xe_2015.3.187/mpirt/lib/intel64:$LIBRARY_PATH

function setup() {
  echo "[INFO] set up"
  rm -rf bench/ && mkdir bench
}

function compile() {
  echo "[INFO] compile"
  icpc -O3 -xHost -openmp sgd_single_node_tiles.cpp -o bench/sgd_single_intel.out
  icpc -DBLAS -O3 -xHost -openmp sgd_single_node_tiles.cpp -o bench/sgd_single_intel_blas.out -lmkl_rt
}

function do_bench() {
  exe_path_=$1
  for i in `seq 1 10`; do
    echo "Iteration: $i"
    $exe_path_ ratings_u10_v9.dat $((1 << 10)) $((1 << 9)) $((1 << 19)) 4
    echo -e "\n"
  done
}

setup
compile
echo "[INFO] start benchmark"
do_bench bench/sgd_single_intel.out > bench/sgd_single_intel.result
do_bench bench/sgd_single_intel_blas.out > bench/sgd_single_intel_blas.result
echo "[INFO] done all benchmark."
