#!/bin/bash
set -e

if [ -d /vagrant ]; then
  source /vagrant/scripts/common.sh
else
  source $(dirname $0)/../scripts/common.sh
fi

function change_libblas_reference() {
  update-alternatives --install /usr/lib/libblas.so     libblas.so     /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000
  update-alternatives --install /usr/lib/libblas.so.3   libblas.so.3   /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000
  update-alternatives --install /usr/lib/liblapack.so   liblapack.so   /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000
  update-alternatives --install /usr/lib/liblapack.so.3 liblapack.so.3 /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000

  #update-alternatives --install /usr/lib/libblas.so.3gf   libblas.so.3gf   /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000
  #update-alternatives --install /usr/lib/liblapack.so.3gf liblapack.so.3gf /opt/intel/mkl/lib/intel64/libmkl_rt.so 1000

  update-alternatives --set libblas.so     /opt/intel/mkl/lib/intel64/libmkl_rt.so
  update-alternatives --set libblas.so.3   /opt/intel/mkl/lib/intel64/libmkl_rt.so
  update-alternatives --set liblapack.so   /opt/intel/mkl/lib/intel64/libmkl_rt.so
  update-alternatives --set liblapack.so.3 /opt/intel/mkl/lib/intel64/libmkl_rt.so

  #update-alternatives --set libblas.so.3gf   /opt/intel/mkl/lib/intel64/libmkl_rt.so 
  #update-alternatives --set liblapack.so.3gf /opt/intel/mkl/lib/intel64/libmkl_rt.so  

  ln -s /opt/intel/mkl/lib/intel64/libmkl_rt.so /usr/lib/libblas.so.3gf
  ln -s /opt/intel/mkl/lib/intel64/libmkl_rt.so /usr/lib/liblapack.so.3gf
}

function update_ld_so_conf() {
  #if ! fgrep mkl /etc/ld.so.conf; then
  #  echo "/opt/intel/lib/intel64" >> /etc/ld.so.conf
  #  echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf
  #fi
  cp $RESOURCES/mkl/mkl.conf /etc/ld.so.conf.d/mkl.conf
  ldconfig
}

if ! ldconfig -p | fgrep mkl; then
  change_libblas_reference
  update_ld_so_conf
fi
