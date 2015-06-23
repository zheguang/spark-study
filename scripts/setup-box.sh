#!bin/bash
set -e

source $(dirname $0)/common.sh

function initThirdParty {
  echo "init third-party submodules"
  git submodule update --init
  (cd $HADOOP_GIT && git checkout branch-$HADOOP_VER-master)
  (cd $SPARK_GIT && git checkout branch-$SPARK_VER-master)
  (cd $PROTOBUF_GIT && git checkout v$PROTOBUF_VER-master)
}

function installProtobuf_ {
  ./autogen.sh
  ./configure --prefix=$INSTALL/protobuf-$PROTOBUF_VER
  make
  make check
  make install
}

function installProtobuf {
  echo "install protobuf"
  (cd $PROTOBUF_GIT && installProtobuf_)
  ln -s $INSTALL/protobuf-$PROTOBUF_VER $INSTALL/protobuf
  assertExists $INSTALL/protobuf
}

function installHadoopDeps {
  echo "install hadoop deps"
  apt-get -y install build-essential autoconf automake pkg-config
  apt-get -y install openjdk-7-jdk openjdk-7-jre openjdk-7-jre-lib 
  apt-get -y install libtool cmake zlib1g-dev libssl-dev
}

function setupJavaEnvVars {
  echo "create java environment variables"
  cp -f $RESOURCES/java/java.sh /etc/profile.d/java.sh
}

function setupProtobufEnvVars {
  echo "set up protobuf environment variables"
  cp -f $RESOURCES/protobuf/protobuf.sh /etc/profile.d/protobuf.sh
}

function main {
  initThirdParty

  installHadoopDeps
  installProtobuf

  setupJavaEnvVars
  setupProtobufEnvVars
}

main $@
