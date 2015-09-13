#!/bin/bash
set -e

function java8_() {
  update-alternatives --set java /usr/local/java/bin/java
  update-alternatives --set javac /usr/local/java/bin/javac
}

function java7_() {
  update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
  update-alternatives --set javac /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/javac
}

function checkJava() {
  java -version
  javac -version
}

ver=$1
if [[ -z $ver ]]; then
  echo "usage: change-java.sh [7|8]"
  exit 1
fi

java${ver}_
checkJava

echo "[info] done"
