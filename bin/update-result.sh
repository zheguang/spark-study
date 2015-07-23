#!/bin/bash

set -e

project_root=$(dirname $0)/..

modes=("cc" "java" "scala")

if [ "${#@}" -eq 0 ]; then
  run_modes=modes
else
  run_modes=$@
fi

for m in ${run_modes[@]}; do
  echo "[info] cp $project_root/study/bench/cfsgd/$m/result/* $project_root/result/cfsgd/$m/"
  cp $project_root/study/bench/cfsgd/$m/result/* $project_root/result/cfsgd/$m/
done

echo "[info] done"
