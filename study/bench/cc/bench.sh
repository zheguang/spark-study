#!/bin/bash
set -e

root=$(readlink -f `dirname $0`)/../..
my_bench=$root/bench/cc
cd $my_bench

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
  rm -rif result/ && mkdir result
}

function compile() {
  mode_=$1
  latent_=$2
  echo "[INFO] compile for mode=$mode_ latent=$latent_"
  src=$root/src/main/cc
  #icpc -O3 -xHost -openmp $src/sgd_single_node_tiles.cpp -o build/sgd_single_intel.out
  #icpc -DBLAS -O3 -xHost -openmp $src/sgd_single_node_tiles.cpp -o build/sgd_single_intel_blas.out -lmkl_rt
  #icpc -DLATENT=$latent_ -D$mode -O3 -xHost -openmp $src/sgd_single_node_tiles.cpp -o build/sgd_single_intel_l${latent_}_${mode}.out
  icpc -DLATENT=$latent_ -D$mode_ -O3 -xHost -openmp $src/sgd_single_node_tiles.cpp -o build/sgd_single_intel_l${latent_}_${mode_}.out -lmkl_rt
}

function do_bench() {
  mode_=$1
  latent_=$2
  exe_path_=build/sgd_single_intel_l${latent_}_${mode_}.out
  if [ ! -e exe_path_ ]; then
    >&2 echo "[error] $exe_path_ does not exist."
    exit 1
  fi
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
  mode_=$1
  latent_=$2
  exe_path_=build/sgd_single_intel_l${latent_}_${mode_}.out
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

modes=("CPP" "BLAS")
#modes=("BLAS")
#latents=("20" "200" "2000")
latents=("20000")

setup
#compile
echo "[info] start compile"
for l in "${latents[@]}"; do
  for m in "${modes[@]}"; do
    compile $m $l
  done
done
echo "[info] end compile"

echo "[INFO] start benchmark"
#do_bench_s20 build/sgd_single_intel.out 1> result/sgd_single_intel.result
#do_bench_s20 build/sgd_single_intel_blas.out 1> result/sgd_single_intel_blas.result
for l in "${latents[@]}"; do
  for m in "${modes[@]}"; do
    do_bench_s20 $m $l build/${exe_name}.out 1> result/sgd_single_intel_l${latent_}_${mode_}.result
  done
done
echo "[INFO] done all benchmark."
