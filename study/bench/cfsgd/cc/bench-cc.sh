#!/bin/bash
set -e

root=$(readlink -f `dirname $0`)/../../..
my_bench=$root/bench/cfsgd/cc
cd $my_bench

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
  rm -rf test/ && mkdir test
  rm -rf build/ && mkdir build
  func_mode_=$1
  if [ $func_mode_ = "result" ]; then
    if [ -d result ]; then
      rm -ri result/ && mkdir result
    else
      mkdir result
    fi
  fi
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
  #icpc -DLATENT=$latent_ -D$mode_ -DDOTPTIME -O3 -xHost -openmp $src/sgd_single_node_tiles.cpp -o build/sgd_single_intel_l${latent_}_${mode_}_dotptime.out -lmkl_rt
  icpc -DLATENT=$latent_ -D$mode_ -O3 -xHost -openmp $src/sgd_single_node_tiles_copyedge.cpp -o build/sgd_single_intel_l${latent_}_${mode_}_copyedge.out -lmkl_rt
}

function test_bench() {
  mode_=$1
  latent_=$2
  datafile=$root/src/main/cc/ratings_u10_v9.dat
  nusers=1024
  nmovies=512
  nratings=524288
  nthreads=4

  actual_bench_
}

function do_bench() {
  mode_=$1
  latent_=$2
  datafile=/data/devel/research/sam/Rating_S20.train
  nusers=996994
  nmovies=20972
  nratings=248944185
  nthreads=8

  actual_bench_
}

function actual_bench_() {
  exe_path_=build/sgd_single_intel_l${latent_}_${mode_}.out
  >&2 echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
  $exe_path_ $datafile $nusers $nmovies $nratings $nthreads

  #exe_dotptime_=build/sgd_single_intel_l${latent_}_${mode_}_dotptime.out
  #$exe_dotptime_ $datafile $nusers $nmovies $nratings $nthreads

  exe_path_=build/sgd_single_intel_l${latent_}_${mode_}_copyedge.out
  >&2 echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
  $exe_path_ $datafile $nusers $nmovies $nratings $nthreads
}

modes=("CPP" "BLAS")
latents=("20")

func_mode="test"
func=test_bench
if [ "$1" = "result" ]; then
  func_mode="result"
  func=do_bench
fi

setup $func_mode
#compile
echo "[info] start compile"
for l in "${latents[@]}"; do
  for m in "${modes[@]}"; do
    compile $m $l
  done
done
echo "[info] end compile"

echo "[INFO] start benchmark: $func_mode"
for l in "${latents[@]}"; do
  for m in "${modes[@]}"; do
    $func $m $l 1> $func_mode/sgd_single_intel_l${l}_${m}.result
    #test_bench $m $l 1> test/sgd_single_intel_l${l}_${m}.result
  done
done
echo "[INFO] done all benchmark: $func_mode"
