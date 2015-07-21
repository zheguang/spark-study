#!/bin/bash

set -e

source $(dirname $0)/../scripts/common.sh

(cd $PROJECT && git submodule update --init)
