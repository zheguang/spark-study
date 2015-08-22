#!/bin/bash

set -e

project_root=$(dirname $0)/..

#modes=("cc" "java" "scala" "spark")
#
#if [ "${#@}" -eq 0 ]; then
#  run_modes=${modes[@]}
#else
#  run_modes=$@
#fi

rev_id=`git rev-parse --short HEAD`

#######
# cfsgd
#######
run_modes=("cc" "java" "scala" "spark")
for m in ${run_modes[@]}; do
  dest=$project_root/result/cfsgd/result.$rev_id/$m
  echo "[info] cfsgd: cp $project_root/study/bench/cfsgd/$m/result/* $dest"
  mkdir -p $dest
  cp $project_root/study/bench/cfsgd/$m/result/* $dest
done

######
# pr
######
dest=$project_root/result/pr/result.$rev_id
mkdir -p $dest
echo "[info] pr: cp $project_root/study/bench/pagerank/*.result $dest"
cp $project_root/study/bench/pagerank/*.result $dest

echo "[info] done"
