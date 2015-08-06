#!/bin/bash

set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

wget http://downloads.typesafe.com/scala/2.11.4/scala-2.11.4.tgz?_ga=1.21732155.1693576347.1436951837 -O $PROJECT/scala-2.11.4.tgz
