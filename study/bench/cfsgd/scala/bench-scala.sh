#!/bin/bash
set -e

project=$(readlink -f `dirname $0`)/../../../..
study=$project/study
my_bench=$(dirname $0)

source $project/scripts/bench-common.sh

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
  (cd $study && sbt assembly)
}

function actual_bench_() {
  echo "[info] set java opts=$JAVA_OPTS"
  if [ $mode = "scala" ]; then
    exe_path_=edu.brown.cs.sparkstudy.ScalaSgd
    >&2 echo "$exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads"
    echo "[info] java_opts=$JAVA_OPTS"
    echo "$exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads"
    scala -cp $fatJar $exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads 
  elif [ $mode = "breeze" ]; then
    exe_path_=edu.brown.cs.sparkstudy.BreezeSgd
    >&2 echo "$exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads"
    echo "$exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads"
    scala -cp $fatJar $exe_path_ $latent $datafile $nusers $nmovies $nratings $nthreads 
  else
    >&2 echo "[error] unsupported mode: $mode"
    exit 1
  fi
}

function test_bench() {
  latent=$1
  mode=$2
  fatJar=$study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  datafile=$study/src/main/cc/ratings_u10_v9.dat
  nusers=1024
  nmovies=512
  nratings=524288
  nthreads=4

  actual_bench_
}

function do_bench() {
  latent=$1
  mode=$2
  fatJar=$study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  datafile=/data/devel/research/sam/Rating_S20.train
  nusers=996994
  nmovies=20972
  nratings=248944185
  nthreads=8

  actual_bench_
}

modes=("scala" "breeze")
latents=("20")

func_mode="test"
func=test_bench
if [ "$1" = "result" ]; then
  func_mode="result"
  func=do_bench
fi

setup $func_mode
compile

java_opts_=$(get_java_opts)
export JAVA_OPTS=$java_opts_
echo "[info] set java opts=$JAVA_OPTS"

echo "[info] start benchmark"
for l in ${latents[@]}; do
  for m in ${modes[@]}; do
    #test_bench 20 1> $my_bench/test/ScalaSgd_l20.result
    $func $l $m 1> $my_bench/$func_mode/ScalaSgd_l${l}_${m}.result
  done
done
echo "[info] end benchmark"
