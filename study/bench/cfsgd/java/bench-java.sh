#!/bin/bash
set -e

project=$(readlink -f `dirname $0`)/../../../..
study=$project/study
my_bench=$(dirname $0)

source $project/scripts/bench-common.sh

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
#source /opt/intel/bin/compilervars.sh intel64
#echo $LD_LIBRARY_PATH

function check_mkl() {
  if ! ldconfig -p | grep mkl &>/dev/null; then
    >&2 echo "[error] mkl libary is not found in system cache."
    exit 1
  fi
}

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

function test_bench() {
  echo "[info] set java opts=$JAVA_OPTS"
  latent=$1
  mode=$2
  fatJar=$study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  datafile=$study/src/main/cc/ratings_u10_v9.dat
  nusers=1024
  nmovies=512
  nratings=524288
  nthreads=4

  exe_path_=com.intel.sparkstudy.matrix.JavaSgdSingleNodeTiles
  >&2 echo "$exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  java $JAVA_OPTS -cp $fatJar $exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads

  #exe_path_dotptime_=com.intel.sparkstudy.matrix.JavaSgdSingleNodeTilesDotPTime
  #>&2 echo "$exe_path_dotptime_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  #echo "$exe_path_dotptime_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  #java -cp $fatJar $exe_path_dotptime_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads
}

function do_bench() { 
  echo "[info] set java opts=$JAVA_OPTS"
  latent=$1
  mode=$2
  fatJar=$study/target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar
  datafile=/data/devel/research/sam/Rating_S20.train
  nusers=996994
  nmovies=20972
  nratings=248944185
  nthreads=8

  exe_path_=com.intel.sparkstudy.matrix.JavaSgdSingleNodeTiles
  >&2 echo "$exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  java $JAVA_OPTS -cp $fatJar $exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads 

  exe_path_=com.intel.sparkstudy.matrix.JavaSgdSingleNodeTilesDotPTime
  >&2 echo "$exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  echo "$exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  java $JAVA_OPTS -cp $fatJar $exe_path_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads 

  #exe_path_dotptime_=com.intel.sparkstudy.matrix.JavaSgdSingleNodeTilesDotPTime
  #>&2 echo "$exe_path_dotptime_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  #echo "$exe_path_dotptime_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads"
  #java -cp $fatJar $exe_path_dotptime_ $mode $latent $datafile $nusers $nmovies $nratings $nthreads 
}

algebra_modes=("blas" "java")
latents=("20")

func_mode="test"
func=test_bench
if [ "$1" = "result" ]; then
  func_mode="result"
  func=do_bench
fi

check_mkl
setup $func_mode
compile

java_opts_=$(get_java_opts)
export JAVA_OPTS=$java_opts_
echo "[info] set java opts=$JAVA_OPTS"


echo "[INFO] start benchmark"
for m in ${algebra_modes[@]}; do
  for l in ${latents[@]}; do
    #do_bench $l $m 1> $my_bench/result/JavaSgdSingleNodeTiles_l${l}_${m}.result
    $func $l $m 1> $my_bench/$func_mode/JavaSgdSingleNodeTiles_l${l}_${m}.result
  done
done
echo "[INFO] end benchmark"
