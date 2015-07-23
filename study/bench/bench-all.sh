#!/bin/bash

set -e

bench_root=$(dirname $0)/cfsgd

benchs=("cc" "java" "scala")

func_mode="test"
if [ "$1" = "result" ]; then
  func_mode="result"
fi

echo "[info] start bench master"
for b in "${benchs[@]}"; do
  echo "[info] start $bench_root/$b"
  bash $bench_root/$b/bench-${b}.sh $func_mode
  echo "[info] end $bench_root/$b"
done

if [ $func_mode = "test" ]; then
  echo "[info] print test outcome"
  for b in "${benchs[@]}"; do
    echo "[info] $b test"
    tail -n 2 $bench_root/$b/test/*
  done
  echo "[info] finish test outcome"
fi

echo "[info] end bench master"
