#!/bin/bash

set -e

sock_pid=""
args=""
func=""
dest="user@10.212.84.159"
gateway="sam_cs.brown.edu@ssh.intel-research.net"

daemons_dir=$HOME/.daemons
mkdir -p $daemons_dir

function show_help {
echo "usage: ssh-intel.sh --[start|stop|ssh|scp] <args...>"
}

function parse_args {
  while :; do
    case $1 in
      -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
        show_help
        exit
        ;;
      --start)
        func=start_sock
        ;;
      --stop)
        func=stop_sock
        ;;
      --ssh)
        func=ssh_
        args=( "${@:2}" )
        shift ${#args[@]}
        ;;
      --scp)
        func=scp_
        args=( "${@:2}" )
        shift ${#args[@]}
        if [ -z $args ]; then
          echo "[error] missing arguments for scp"
          show_help
          exit 1
        fi
        ;;
      --)              # End of all options.
        shift
        break
        ;;
      -?*)
        printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
        ;;
      *)               # Default case: If no more options then break out of the loop.
        break
    esac

    shift
  done
}

function is_sock_running {
  [ -e $daemons_dir/sock_pid ]
}

function start_sock {
  if is_sock_running; then
    echo "[warn] found sock pid, try to termiante it"
    stop_sock
  fi

  echo "[info] start sock"
  yes | ssh -N -D 1080 $gateway -v &>/tmp/ssh-intel.log &
  sock_pid=$!
  status_=$?
  if [ $status_ -eq 0 ]; then
    echo "[info] sock started with pid: $sock_pid"
    echo $sock_pid > /$daemons_dir/sock_pid
  else
    echo "[error] sock start failed."
    exit 1
  fi
}

function remove_sock_pid_file {
  echo "[info] remove sock pid file"
  rm -f $daemons_dir/sock_pid
}

function stop_sock {
  echo "[info] stop sock"
  if ! is_sock_running $sock_pid; then
    echo "[warn] no sock pid found in $daemons_dir"
    exit 0
  fi
  sock_pid=$(head -n 1 $daemons_dir/sock_pid)
  if [ -z sock_pid ]; then
    echo "[warn] no sock pid found in $daemons_dir/sock_pid"
    remove_sock_pid_file
    exit 0
  fi

  if ! ps aux | grep $sock_pid &>/dev/null; then
    echo "[warn] ps did not find $sock_pid"
    rm -f $daemons_dir/sock_pid
    exit 0
  fi

  echo "[info] terminate $sock_pid"
  kill -TERM $sock_pid
  status_=$?

  if [ $status_ -ne 0 ]; then
    echo "[info] termination did not succeed. Try to kill $sock_pid"
    kill -9 $sock_pid
    status_=$?
  fi
  if [ $status_ -ne 0 ]; then
    echo "[info] kill did not succeed for $sock_pid"
    exit 1
  fi

  remove_sock_pid_file
}

function ssh_ {
  if ! is_sock_running; then
    echo "[error] sock is not running. Please use --start to start sock."
    exit 1
  fi
  echo "[info] ssh: $dest"
  ssh -o ProxyCommand='nc -X 5 -x localhost:1080 %h %p' $dest ${args[@]}
}

function scp_ {
  echo "[info] scp: ${args[0]} $dest:${args[1]}"
  scp -o ProxyCommand='nc -X 5 -x localhost:1080 %h %p' ${args[0]} $dest:${args[1]}
}

function main {
  parse_args $@

  #echo "func=$func"
  #echo "arg[0]=${args[0]}"
  #echo "args=$args"
  #echo "args=${args[@]}"

  if [ -z "$func" ]; then
    show_help
  fi
  $func
}

main $@
