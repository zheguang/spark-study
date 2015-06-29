#!/bin/bash
set -e

source /vagrant/scripts/common.sh

function initThirdParty {
  log "init third-party submodules"
  (cd $PROJECT && git submodule update --init)
  (cd $HADOOP_GIT && git checkout branch-$HADOOP_VER-master)
  (cd $SPARK_GIT && git checkout branch-$SPARK_VER-master)
  (cd $PROTOBUF_GIT && git checkout v$PROTOBUF_VER-master)
}

function installProtobuf_ {
  log "build protobuf"
  ./autogen.sh
  ./configure --prefix=$INSTALL/protobuf-$PROTOBUF_VER
  make clean
  make -j
  make install
  tar cf $RESOURCES/$PROTOBUF_ARCHIVE $INSTALL/protobuf-$PROTOBUF_VER 
}

function setupProtobuf {
  log "install protobuf"
  #(cd $PROTOBUF_GIT && installProtobuf_)
  assertExists $RESOURCES/$PROTOBUF_ARCHIVE
  tar xf $RESOURCES/$PROTOBUF_ARCHIVE -C $INSTALL
  ln -s $INSTALL/${PROTOBUF_ARCHIVE%.*} $INSTALL/protobuf
  assertExists $INSTALL/protobuf
}

function installHadoopDeps {
  log "install hadoop deps"
  apt-get -y install build-essential autoconf automake pkg-config
  apt-get -y install openjdk-7-jdk openjdk-7-jre openjdk-7-jre-lib 
  apt-get -y install libtool cmake zlib1g-dev libssl-dev
}

function installPackages {
  apt-get -y install make gcc g++ python python-numpy git cmake ant
}

function setupJavaEnvVars {
  log "create java environment variables"
  ln -s /usr/lib/jvm/java-7-openjdk-amd64 $INSTALL/java
  cp -f $RESOURCES/java/java.sh /etc/profile.d/java.sh
}

function setupProtobufEnvVars {
  log "set up protobuf environment variables"
  cp -f $RESOURCES/protobuf/protobuf.sh /etc/profile.d/protobuf.sh
}

function main {
  installHadoopDeps
  installPackages

  #initThirdParty

  setupProtobuf

  setupJavaEnvVars
  setupProtobufEnvVars
}

main $@
