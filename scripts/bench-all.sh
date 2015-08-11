#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

bench_cfsgd=$PROJECT/study/bench/cfsgd

func_mode="test"
benchs=("cc" "java" "scala" "spark")

function show_help {
  echo "usage: bench-all.sh -m <test|result> -b <cc|java|scala|spark>..."
}

function parse_args {
  while :; do
    case $1 in
      -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
        show_help
        exit
        ;;
      -m)
        func_mode=$2
        shift
        ;;
      -b)
        benchs=( "${@:2}" )
        shift ${#benchs[@]}
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

  if [ -z $func_mode ] || [ -z $benchs ]; then
    echo "[error] wrong arguments."
    show_help
    exit 1
  fi
}

function main {
  echo "[info] start bench master"
  for b in "${benchs[@]}"; do
    echo "[info] start $bench_cfsgd/$b"
    bash $bench_cfsgd/$b/bench-${b}.sh $func_mode
    echo "[info] end $bench_cfsgd/$b"
  done

  if [ $func_mode = "test" ]; then
    echo "[info] print test outcome"
    for b in "${benchs[@]}"; do
      echo "[info] $b test"
      tail -n 2 $bench_cfsgd/$b/test/*
    done
    echo "[info] finish test outcome"
  else
    echo "[info] collect test outcome"
    all_results=$bench_cfsgd/all-results
    my_result=$all_results/result.`date +%Y%m%d.%H%M`
    mkdir -p $all_results
    mkdir $my_result
    for b in "${benchs[@]}"; do
      echo "[info] $b test"
      mkdir -p $my_result/$b
      mv $bench_cfsgd/$b/result/* $my_result/$b
    done
  fi

  echo "[info] end bench master"
}

parse_args $@
main
