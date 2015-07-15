#!/bin/bash
set -e

root=$(readlink -f `dirname $0`)/../..
my_bench=$(dirname $0)

#source /opt/intel/bin/compilervars.sh intel64

function check_mkl() {
  if ! ldconfig -p | grep mkl &>/dev/null; then
    >&2 echo "[error] mkl libary is not found in system cache."
    exit 1
  fi
}

function setup() {
  echo "[INFO] set up"
  (cd $my_bench && rm -rif result/ && mkdir result)
}

function compile() {
  echo "[INFO] compile"
  (cd $root && sbt assembly)
}

function do_bench() { 
  latent=$1
  fatJar=$root/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  datafile=/ext/research/graphmat/datasets/Rating_S20.train
  nusers=996994
  nmovies=20972
  nratings=248944185
  nthreads=8

  exe_path_=com.intel.sparkstudy.matrix.JavaSgdSingleNodeTiles
  >&2 echo "$exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  #java -cp target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar com.intel.sparkstudy.matrix.JavaSgdSingleNodeTiles $mode $root/src/main/cc/ratings_u10_v9.dat $((1 << 10)) $((1 << 9)) $((1 << 19)) 4
  java -cp $fatJar $exe_path_ $mode $latent $root/src/main/cc/ratings_u10_v9.dat $((1 << 10)) $((1 << 9)) $((1 << 19)) 4
  #java -cp $fatJar $exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads 
}

algebra_modes=("blas" "java")

check_mkl
#setup
compile

echo "[INFO] start benchmark"
for mode in ${algebra_modes[@]}; do
  do_bench 20 1> $my_bench/result/JavaSgdSingleNodeTiles_l20_${mode}.result
  do_bench 200 1> $my_bench/result/JavaSgdSingleNodeTiles_l200_${mode}.result
done
echo "[INFO] end benchmark"
