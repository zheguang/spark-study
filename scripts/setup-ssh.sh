#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
elif
  source $(dirname $0)/../scripts/common.sh
fi

NODE_ID=0

function parseNodeId {
  log "get number of nodes"
  while getopts ":i:" opt; do
    case $opt in
      i)
        NODE_ID=$OPTARG
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
  done
}

function installSSHPass {
  log "install sshpass for non-interactive ssh authentication"
  apt-get install sshpass
}

function createSSHKey {
  log "create ssh key"
  ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  cp -f $RESOURCES/ssh/config ~/.ssh
}

function overwriteSSHCopyId {
  log "overwrite ssh-copy-id to use sshpass"
  cp -f $RESOURCES/ssh/ssh-copy-id-modify /usr/bin/ssh-copy-id
}

function exchangeSSHIds {
  log "exchange ssh public keys"
  for i in $(seq 1 $NODE_ID); do
    node_="node$i"
    if [ $node_ != $HOSTNAME ]; then
      log "copy ssh public key from $HOSTNAME to $node_"
      ssh-copy-id -i ~/.ssh/id_rsa.pub $node_
      log "copy ssh public key from $node_ to $HOSTNAME"
      ssh $node_ "ssh-copy-id -i ~/.ssh/id_rsa.pub $HOSTNAME"
    fi
  done
}

function main {
  parseNodeId $@
  installSSHPass
  createSSHKey
  overwriteSSHCopyId
  exchangeSSHIds
}

main $@
