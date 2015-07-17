#!/bin/bash

set -e

bench_root=$(dirname $0)

benchs=("cc/bench-cc.sh" "java/bench-java.sh")

echo "[info] start bench master"
for b in "${benchs[@]}"; do
  echo "[info] start $bench_root/$b"
  bash $bench_root/$b
  echo "[info] end $bench_root/$b"
done
echo "[info] end bench master"
