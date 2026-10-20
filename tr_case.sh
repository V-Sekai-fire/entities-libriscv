#!/bin/bash
# Run one libriscv unit test case binary-translated, with the riscv64-sysroot checkout's
# pixi clang and lld as the guest compiler.  ./tr_case.sh <build dir> "<test case name>"
set -e
RV=$HOME/Desktop/smoke-water/5-repository/riscv64-sysroot
B=$RV/.pixi/envs/default/bin
S=$RV/sysroot
G=$S/lib/gcc-cross/14
FLAGS="--target=riscv64-unknown-linux-gnu --sysroot=$S -fuse-ld=lld --ld-path=$B/ld.lld -B$G -L$G -Wno-unused-command-line-argument"
export RCC="$B/clang $FLAGS"
export RCXX="$B/clang++ $FLAGS -isystem $S/include/c++/14 -isystem $S/include/c++/14/riscv64-linux-gnu"
export BINTR_CACHE=0 CFLAGS=-O0
SRC=$(cd "$(dirname "$0")" && pwd)/tests/unit
mkdir -p "$1"
cd "$1"
[ -f CMakeCache.txt ] || cmake "$SRC" -G Ninja -DCMAKE_BUILD_TYPE=Debug -DRISCV_BINARY_TRANSLATION=ON -DRISCV_EXT_C=ON -DRISCV_THREADED=ON > cmake.log
ninja fptest > ninja.log 2>&1 || { tail -30 ninja.log; exit 1; }
rm -f /tmp/binary-* /tmp/rvbintr-*
./fptest ${2:+"$2"} 2>&1 | tail -25
