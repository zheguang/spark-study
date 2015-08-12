#!/bin/bash

set -e

project_root=$(dirname $0)/..

modes=("cc" "java" "scala" "spark")

if [ "${#@}" -eq 0 ]; then
  run_modes=${modes[@]}
else
  run_modes=$@
fi

rev_id=`git rev-parse --short HEAD`

for m in ${run_modes[@]}; do
  dest=$project_root/result/cfsgd/result.$rev_id/$m
  echo "[info] cp $project_root/study/bench/cfsgd/$m/result/* $dest"
  mkdir -p $dest
  cp $project_root/study/bench/cfsgd/$m/result/* $dest
done

echo "[info] done"
