#!/bin/bash
set -e

NUM_ITERS=2

source /opt/intel/bin/compilervars.sh intel64
#export LD_LIBRARY_PATH=/opt/intel/composer_xe_2015.3.187/compiler/lib/intel64:/opt/intel/composer_xe_2015.3.187/mpirt/lib/intel64:$LD_LIBRARY_PATH
#export LIBRARY_PATH=/opt/intel/composer_xe_2015.3.187/compiler/lib/intel64:/opt/intel/composer_xe_2015.3.187/mpirt/lib/intel64:$LIBRARY_PATH
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/include/x86_64-linux-gnu/c++/4.8

datafile=$1
nusers=$2
nmovies=$3
#nratings=$((nusers * nmovies))
nratings=$4
nthreads=$5

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
  >&2 echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
  for i in $(seq 1 $NUM_ITERS); do
    echo "Iteration: $i"
    #$exe_path_ ratings_u10_v9.dat $((1 << 10)) $((1 << 9)) $((1 << 19)) 4
    $exe_path_ $datafile $nusers $nmovies $nratings $nthreads
    echo -e "\n"
  done
}

setup
compile
echo "[INFO] start benchmark"
do_bench bench/sgd_single_intel.out 1> bench/sgd_single_intel.result
do_bench bench/sgd_single_intel_blas.out 1> bench/sgd_single_intel_blas.result
echo "[INFO] done all benchmark."
