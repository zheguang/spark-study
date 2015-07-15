#!bin/bash
set -e

root=$(readlink -f `dirname $0`)/../..

function setup() {
  echo "[INFO] set up"
  rm -rf result/ && mkdir result
}

function compile() {
  echo "[INFO] compile"
  (cd $root && sbt assembly)
}

function do_bench() { 
  echo "[INFO] start benchmark"
  fatJar=$root/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  algebra_modes=("java" "blas")
  datafile=/ext/research/graphmat/datasets/Rating_S20.train
  nusers=996994
  nmovies=20972
  nratings=248944185
  nthreads=8
  for mode in ${algebra_modes[@]}; do
    exe_path_=com.intel.sparkstudy.matrix.JavaSgdSingleNodeTiles
    >&2 echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
    echo "$exe_path_ $datafile $nusers $nmovies $nratings $nthreads"
    #java -cp target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar com.intel.sparkstudy.matrix.JavaSgdSingleNodeTiles $mode $root/src/main/cc/ratings_u10_v9.dat $((1 << 10)) $((1 << 9)) $((1 << 19)) 4
    java -cp $fatJar $exe_path_ $mode $datafile $nusers $nmovies $nratings $nthreads 1> result/${exe_path_}_${mode}.result
  done
  echo "[INFO] end benchmark"
}

setup
compile
do_bench
