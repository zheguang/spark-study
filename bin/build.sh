#!/bin/bash
set -e

REPO=$(dirname $0)/..

(cd $REPO/scripts && /bin/bash build-protobuf.sh)
(cd $REPO/scripts && /bin/bash build-hadoop.sh)
(cd $REPO/scripts && /bin/bash build-spark.sh)
