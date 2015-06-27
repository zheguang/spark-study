#!/bin/bash
set -e

source $(dirname $0)/../scripts/common.sh

function buildProtobuf {
  log "build protobuf"
  ./autogen.sh
  ./configure --prefix=$LOCAL_PROJECT/third_party/protobuf/dist/protobuf-$PROTOBUF_VER
  make clean
  make -j
  make install
  (cd $LOCAL_PROJECT/third_party/protobuf/dist && tar cf $LOCAL_PROJECT/third_party/protobuf/protobuf-$PROTOBUF_VER.tar ./protobuf-$PROTOBUF_VER )
}

(cd $LOCAL_PROJECT/third_party/protobuf && buildProtobuf)
