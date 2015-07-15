#!/bin/bash
set -e

root=$(readlink -f `dirname $0`)/../..

NUM_ITERS=1

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
  rm -rf build/ && mkdir build
  rm -rf result/ && mkdir result
}

function compile() {
  echo "[INFO] compile"
  src=$root/src/main/cc
  icpc -O3 -xHost -openmp $src/sgd_single_node_tiles.cpp -o build/sgd_single_intel.out
  icpc -DBLAS -O3 -xHost -openmp $src/sgd_single_node_tiles.cpp -o build/sgd_single_intel_blas.out -lmkl_rt

  icpc -DLATENT=200 -O3 -xHost -openmp $src/sgd_single_node_tiles.cpp -o build/sgd_single_intel_l200.out
  icpc -DLATENT=200 -DBLAS -O3 -xHost -openmp $src/sgd_single_node_tiles.cpp -o build/sgd_single_intel_l200_blas.out -lmkl_rt
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

function do_bench_s20() {
  exe_path_=$1
  datafile=/ext/research/graphmat/datasets/Rating_S20.train
  nusers=996994
  nmovies=20972
  nratings=248944185
  nthreads=8
  >&2 echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
  for i in $(seq 1 $NUM_ITERS); do
    echo "Iteration: $i"
    $exe_path_ $datafile $nusers $nmovies $nratings $nthreads
    #$exe_path_ /ext/research/graphmat/datasets/Rating_S20.train 996994 20972 248944185 8
    echo -e "\n"
  done
}

exe_names=("sgd_single_intel" "sgd_single_intel_blas" "sgd_single_intel_l200" "sgd_single_intel_l200_blas")

setup
compile
echo "[INFO] start benchmark"
#do_bench_s20 build/sgd_single_intel.out 1> result/sgd_single_intel.result
#do_bench_s20 build/sgd_single_intel_blas.out 1> result/sgd_single_intel_blas.result
for exe_name in "${exe_names[@]}"; do
  do_bench_s20 build/${exe_name}.out 1> result/${exe_name}.result
done
echo "[INFO] done all benchmark."
