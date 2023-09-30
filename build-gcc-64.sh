#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0
# Author: Vaisakh Murali & pdx
set -e

echo "*****************************************"
echo "* Building Bare-Metal Bleeding Edge GCC *"
echo "*****************************************"

# TODO: Add more dynamic option handling
while getopts a: flag; do
  case "${flag}" in
    a) arch=${OPTARG} ;;
    *) echo "Invalid argument passed" && exit 1 ;;
  esac
done

# TODO: Better target handling
case "${arch}" in
  "arm") TARGET="arm-linux-gnueabi" ;;
  "arm64") TARGET="aarch64-linux-gnu" ;;
   #"arm") TARGET="arm-eabi" ;;
   #"arm64") TARGET="aarch64-elf" ;;
 #"arm64gnu") TARGET="aarch64-linux-gnu" ;;
  "x86") TARGET="x86_64-elf" ;;
esac

export WORK_DIR="$PWD"
export PREFIX=$WORK_DIR/../pdx-gcc-`date +'%Y%m%d'`
export PATH="$PREFIX/bin:/usr/bin/core_perl:$PATH"
#export OPT_FLAGS="-flto -flto-compression-level=10 -O3 -pipe -ffunction-sections -fdata-sections"
#

echo "Cleaning up previously cloned repos..."
rm -rf $WORK_DIR/{build-binutils,build-gcc,gcc,binutils}

echo "||                                                                    ||"
echo "|| Building Bare Metal Toolchain for ${arch} with ${TARGET} as target ||"
echo "||                                                                    ||"

download_resources() {
  echo "Downloading Pre-requisites"
  echo "Cloning binutils"
  #git clone git://sourceware.org/git/binutils-gdb.git -b master binutils --depth=1
  git clone https://mirrors.tuna.tsinghua.edu.cn/git/binutils-gdb.git binutils --depth=1
  sed -i '/^development=/s/true/false/' binutils/bfd/development.sh
  
  
  echo "Cloned binutils!"
  echo "Cloning GCC"
  #git clone git://gcc.gnu.org/git/gcc.git -b master gcc --depth=1
  git clone https://mirrors.tuna.tsinghua.edu.cn/git/gcc.git gcc --depth=1
  cd "${WORK_DIR}"
  echo "Downloaded prerequisites!"
}

build_binutils() {
  cd "${WORK_DIR}"
  echo "Building Binutils"
  mkdir build-binutils
  cd build-binutils
  env CFLAGS="$OPT_FLAGS" CXXFLAGS="$OPT_FLAGS" \
    ../binutils/configure --target=$TARGET \
    --disable-docs \
    --disable-gdb \
    --disable-nls \
    --disable-werror \
    --enable-gold \
    --prefix="$PREFIX" \
    --with-pkgversion="Pdx Binutils" \
    --with-sysroot
  make -j8
  make install -j8
  cd ../
  echo "Built Binutils, proceeding to next step...."
}

build_gcc() {
  cd "${WORK_DIR}"
  echo "Building GCC"
  cd gcc
  ./contrib/download_prerequisites
  echo "Bleeding Edge" > gcc/DEV-PHASE
  cd ../
  mkdir build-gcc
  cd build-gcc
  env CFLAGS="$OPT_FLAGS" CXXFLAGS="$OPT_FLAGS" \
   ../gcc/configure --target=$TARGET \
    --prefix="$PREFIX" \
    --enable-languages=c,c++,fortran \
    --disable-multilib \
    --disable-docs \
    --disable-threads \
    --disable-decimal-float \
    --disable-shared \
    --disable-nls\
    --disable-libmudflap \
    --disable-libssp \
    --with-gnu-as \
    --with-gnu-ld \
    --with-newlib \
    --with-pkgversion="Pdx GCC" \
    --with-sysroot \
    --with-linker-hash-style=gnu \
    --disable-werror \
    --enable-bionic-libs \
    --enable-fix-cortex-a53-835769 \
    --enable-fix-cortex-a53-843419 \
    --enable-libatomic-ifuncs=no \
    --enable-initfini-array \
    --enable-gold \
    --enable-target-optspace \
    --enable-libatomic-ifuncs=no \
    --enable-gnu-indirect-function 
    
    make -j8 all-gcc 
    make -j8 install-gcc
    make -j8 all-target-libgcc 
    make -j8 install-target-libgcc
  
  echo "Built GCC!"
  rm $PREFIX/bin/aarch64-linux-gnu-aarch64-linux-gnu-*
  cd ..
}

download_resources
build_binutils
build_gcc

