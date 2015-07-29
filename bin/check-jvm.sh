#!/bin/bash

set -e

java -XX:+PrintFlagsFinal -version | egrep -i 'HeapSize|PermSize|THreadStateSize'
