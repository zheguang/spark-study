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

for d in "cfsgd" "pagerank"; do
  src=$project_root/study/bench/$d
  dest=$project_root/result/$d/result.$rev_id
  mkdir -p $dest
  echo "[info] $d: cp $project_root/study/bench/$d/*.result $dest"
  cp $src/*.result $dest
done

echo "[info] done"
