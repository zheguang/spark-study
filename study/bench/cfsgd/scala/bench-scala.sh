#!/bin/bash
set -e

root=$(readlink -f `dirname $0`)/../../..
my_bench=$(dirname $0)

function setup() {
  echo "[INFO] set up"
  func_mode_=$1
  if [ $func_mode_ = "result" ]; then
    if [ -d $my_bench/result ]; then
      (cd $my_bench && rm -ri result/ && mkdir result)
    else
      (cd $my_bench && mkdir result)
    fi
  fi
  (cd $my_bench && rm -rf test/ && mkdir test)
}

function compile() {
  echo "[INFO] compile"
  (cd $root && sbt assembly)
}

function actual_bench_() {
  exe_path_=edu.brown.cs.sparkstudy.ScalaSgd
  >&2 echo "$exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads"
  scala -cp $fatJar $exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads 

  exe_path_=edu.brown.cs.sparkstudy.BreezeSgd
  >&2 echo "$exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads"
  scala -cp $fatJar $exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads 
}

function test_bench() {
  latent=$1
  fatJar=$root/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  datafile=$root/src/main/cc/ratings_u10_v9.dat
  nusers=1024
  nmovies=512
  nratings=524288
  nthreads=4

  actual_bench_
}

function do_bench() {
  latent=$1
  fatJar=$root/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  datafile=/ext/research/graphmat/datasets/Rating_S20.train
  nusers=996994
  nmovies=20972
  nratings=248944185
  nthreads=8

  actual_bench_
}

modes=("scala")
latents=("20" "200")

func_mode="test"
func=test_bench
if [ "$1" = "result" ]; then
  func_mode="result"
  func=do_bench
fi

setup $func_mode
compile

echo "[info] start benchmark"
for l in ${latents[@]}; do
  for m in ${modes[@]}; do
    #test_bench 20 1> $my_bench/test/ScalaSgd_l20.result
    $func $l 1> $my_bench/$func_mode/ScalaSgd_l${l}_${m}.result
  done
done
echo "[info] end benchmark"
