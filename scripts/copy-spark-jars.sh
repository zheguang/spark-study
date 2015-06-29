#!/bin/bash
set -e

(cd $(dirname $0)/.. && cp third_party/spark/dist/lib/*.jar study/lib/)
