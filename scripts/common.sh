PROJECT=$(dirname $0)/..
RESOURCES=$PROJECT/resources

INSTALL=/usr/local
RUNTIME=/var

PROTOBUF_GIT=$PROJECT/third_party/protobuf
PROTOBUF_VER=2.5.0

HADOOP_GIT=$PROJECT/third_party/hadoop
HADOOP_VER_MAJOR=2.4
HADOOP_VER_MINOR=1
HADOOP_VER=${HADOOP_VER_MAJOR}.${HADOOP_VER_MINOR}
HADOOP_ARCHIVE=hadoop-${HADOOP_VER}.tar.gz
HADOOP_PREFIX=$INSTALL/hadoop
HADOOP_CONF=$HADOOP_PREFIX/etc/hadoop

SPARK_GIT=$PROJECT/third_party/spark
SPARK_VER=1.4
SPARK_ARCHIVE=spark-${SPARK_VER}.0-SNAPSHOT-bin-hadoop-${HADOOP_VER_MAJOR}.tgz
SPARK_PREFIX=$INSTALL/spark
SPARK_CONF=$SPARK_PREFIX/conf

MAVEN=$SPARK_GIT/build/mvn
MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

function assertExists {
  if [ -e $1 ]; then
    return 0
  else
    echo "[ERROR] file does not exist: $1"
    return 1
  fi
}
