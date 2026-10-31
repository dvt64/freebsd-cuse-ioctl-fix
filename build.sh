#!/bin/sh
# Build patched cuse.ko from /usr/src
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
SRCTOP=$ROOT/src-tree
KO_OUT=$ROOT/cuse.ko

rm -rf "$SRCTOP"
mkdir -p "$SRCTOP/sys/fs/cuse" "$SRCTOP/sys/modules/cuse"

cp /usr/src/sys/fs/cuse/* "$SRCTOP/sys/fs/cuse/"
cp /usr/src/sys/modules/cuse/Makefile "$SRCTOP/sys/modules/cuse/"
patch -d "$SRCTOP" -p0 < "$ROOT/patch-sys_fs_cuse_cuse.c"

cd "$SRCTOP/sys/modules/cuse"
make SRCTOP="$SRCTOP" SYSDIR=/usr/src/sys clean depend all

cp -f "$SRCTOP/sys/modules/cuse/cuse.ko" "$KO_OUT"

echo "Built: $KO_OUT"
