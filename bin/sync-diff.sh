#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

patch=/tmp/my.patch
git diff --cached --no-prefix &> $patch

if [ -s "$patch" ]; then
  bash $PROJECT/bin/ssh-intel.sh --scp $patch /tmp
  bash $PROJECT/bin/ssh-intel.sh --ssh "(cd sam/devel/spark-study/ && git reset --hard HEAD && git clean -f && patch -p0 < $patch)"
  echo "[info] done."
else
  echo "[error] diff --cached is empty."
fi
