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
  (cd $LOCAL_PROJECT/third_party/protobuf/dist && tar cf $LOCAL_PROJECT/third_party/protobuf/$PROTOBUF_ARCHIVE ./protobuf-$PROTOBUF_VER )
}

function copyArchive {
  cp $LOCAL_PROJECT/third_party/protobuf/$PROTOBUF_ARCHIVE $LOCAL_PROJECT/resources/
}

(cd $LOCAL_PROJECT/third_party/protobuf && buildProtobuf)
copyArchive
