#!/bin/bash
set -e

function change_libblas_reference() {
  update-alternatives --install /usr/lib/libblas.so     libblas.so     /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000
  update-alternatives --install /usr/lib/libblas.so.3   libblas.so.3   /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000
  update-alternatives --install /usr/lib/liblapack.so   liblapack.so   /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000
  update-alternatives --install /usr/lib/liblapack.so.3 liblapack.so.3 /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000
}

function update_ld_so_conf() {
  if ! fgrep mkl /etc/ld.so.conf; then
    echo "/opt/intel/lib/intel64" >> /etc/ld.so.conf
    echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf
  fi
  ldconfig
}

if ! ldconfig -p | fgrep mkl; then
  change_libblas_reference
  update_ld_so_conf
fi
