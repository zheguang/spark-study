#!bin/bash
set -e

root=$(readlink -f `dirname $0`)/..

cd $root

algebra_modes=("java" "blas")

for mode in ${algebra_modes[@]}; do
  set -x
  java -cp target/scala-2.11/study-assembly-0.1-SNAPSHOT.jar com.intel.sparkstudy.matrix.JavaSgdSingleNodeTiles $mode $root/src/main/cc/ratings_u10_v9.dat $((1 << 10)) $((1 << 9)) $((1 << 19)) 4
  set +x
done

