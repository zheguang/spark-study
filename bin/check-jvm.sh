#!/bin/bash

set -e

java -server -XX:+PrintFlagsFinal -version | egrep -i 'HeapSize|PermSize|THreadStateSize'

# java opt
#-server -XX:+HeapDumpOnOutOfMemoryError  -XX:ErrorFile=/var/local/java/hs_err_pid.log -XX:HeapDumpPath=/var/local/java
