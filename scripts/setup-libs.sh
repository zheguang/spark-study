#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

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
  ln -f -s $INSTALL/${PROTOBUF_ARCHIVE%.*} $INSTALL/protobuf
  assertExists $INSTALL/protobuf

  #update-alternatives --install /usr/bin/protoc protoc $INSTALL/protobuf/bin/protoc 1000
  #update-alternatives --set protoc $INSTALL/protobuf/bin/protoc
  
  cp -f $RESOURCES/protobuf/protobuf.sh /etc/profile.d/protobuf.sh

  cp -f $RESOURCES/protobuf/protobuf.conf /etc/ld.so.conf.d/protobuf.conf
  ldconfig
}

function installMaven3 {
  log "install maven3"
  (cd /tmp && wget --no-check-certificate --no-cookies ftp://mirror.reverse.net/pub/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz)
  tar -xzf /tmp/apache-maven-3.3.3-bin.tar.gz -C $INSTALL
  assertExists $INSTALL/apache-maven-3.3.3
}

function setupMaven3 {
  log "set up maven3"
  ln -f -s $INSTALL/apache-maven-3.3.3 $INSTALL/maven
  cp -f $RESOURCES/maven/maven.sh /etc/profile.d/maven.sh
  update-alternatives --install /usr/bin/mvn mvn $INSTALL/maven/bin/mvn 1000
  update-alternatives --set mvn $INSTALL/maven/bin/mvn
}

function installHadoopDeps {
  log "install hadoop deps"
  apt-get -y install build-essential autoconf automake pkg-config
  #apt-get -y install openjdk-7-jdk openjdk-7-jre openjdk-7-jre-lib 
  apt-get -y install libtool cmake zlib1g-dev libssl-dev
}

function installPackages {
  log "install packages"
  apt-get -y install make gcc g++ python python-numpy git cmake ant
}

function installJava {
  log "install java"
  (cd /tmp && wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u51-b16/jdk-8u51-linux-x64.tar.gz)
  tar xf /tmp/jdk-8u51-linux-x64.tar.gz -C $INSTALL
  assertExists $INSTALL/jdk1.8.0_51
}

function setupJava {
  log "set up java"
  #ln -f -s /usr/lib/jvm/java-7-openjdk-amd64 $INSTALL/java
  assertExists $INSTALL/jdk1.8.0_51
  ln -f -s $INSTALL/jdk1.8.0_51 $INSTALL/java
  cp -f $RESOURCES/java/java.sh /etc/profile.d/java.sh
  update-alternatives --install /usr/bin/java java $INSTALL/java/bin/java 1000
  update-alternatives --install /usr/bin/javac javac $INSTALL/java/bin/javac 1000
  update-alternatives --set java $INSTALL/java/bin/java
  update-alternatives --set javac $INSTALL/java/bin/javac
}

function installScala {
  log "install scala"
  (cd /tmp && wget --no-check-certificate --no-cookies http://downloads.typesafe.com/scala/2.11.7/scala-2.11.7.tgz?_ga=1.74581526.522996698.1433558899 -O scala-2.11.7.tgz)
  tar xf /tmp/scala-2.11.7.tgz -C $INSTALL
  assertExists $INSTALL/scala-2.11.7
}

function setupScala {
  log "set up scala"
  assertExists $INSTALL/scala-2.11.7
  ln -f -s $INSTALL/scala-2.11.7 $INSTALL/scala
  cp -f $RESOURCES/scala/scala.sh /etc/profile.d/scala.sh
  update-alternatives --install /usr/bin/scala scala $INSTALL/scala/bin/scala 1000
  update-alternatives --install /usr/bin/scalac scalac $INSTALL/scala/bin/scalac 1000
  update-alternatives --set scala $INSTALL/scala/bin/scala
  update-alternatives --set scalac $INSTALL/scala/bin/scalac
}

function setupProtobufEnvVars {
  log "set up protobuf environment variables"
}

function main {
  installMaven3
  setupMaven3
  installJava
  setupJava
  installScala
  setupScala

  installHadoopDeps
  installPackages

  #initThirdParty

  setupProtobuf
}

main $@
