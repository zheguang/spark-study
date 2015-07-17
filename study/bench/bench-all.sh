#!/bin/bash

bench_root=$(dirname $0)

benchs=("cc/bench-cc.sh" "java/bench-java.sh")

for b in "${benchs[@]}"; do
  bash $bench_root/$b
done
