#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

NUM_NODES=0
NODE_ID=0

function parseArgs {
  log "parse arguments"
  while getopts ":i::n:" opt; do
    case $opt in
      n)
        NUM_NODES=$OPTARG
        ;;
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

function disableFirewall {
  log "disable firewall"
  ufw disable
}

function aptGetUpdate {
  apt-get update
}

function setPasswords {
  echo "root:vagrant" | chpasswd
  echo "vagrant:vagrant" | chpasswd
}

function setupHosts {
  log "modify /etc/hosts file"
  for i in $(seq 1 $NUM_NODES); do
    entry="10.211.55.10$i node$i"
    log "adding $entry"
    echo $entry >> /tmp/hosts
  done
  echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" >> /tmp/hosts
  echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /tmp/hosts
  mv /etc/hosts /etc/hosts.orig
  mv /tmp/hosts /etc/hosts
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
  parseArgs $@
  disableFirewall
  setPasswords
  setupHosts
  aptGetUpdate

  installSSHPass
  createSSHKey
  overwriteSSHCopyId
  exchangeSSHIds
}

main $@
