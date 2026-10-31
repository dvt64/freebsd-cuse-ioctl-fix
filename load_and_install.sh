#!/bin/sh
# Install and permanently replace system cuse.ko with the patched module. Run as root.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
KO=${1:-"$ROOT/cuse.ko"}

if [ "$(id -u)" -ne 0 ]; then
        echo "run as root: sudo $0" >&2
        exit 1
fi
if [ ! -f "$KO" ]; then
        echo "missing $KO — run ./build.sh first" >&2
        exit 1
fi

# Drop users of cuse before unload
if [ -x /usr/local/etc/rc.d/webcamd ]; then
        /usr/local/etc/rc.d/webcamd stop 2>/dev/null || true
fi
pkill -TERM webcamd 2>/dev/null || true
sleep 1
pkill -KILL webcamd 2>/dev/null || true
sleep 1

if kldstat -n cuse >/dev/null 2>&1; then
        kldunload cuse || {
                echo "kldunload cuse failed — something still holds cuse" >&2
                fuser /dev/cuse 2>/dev/null || true
                exit 1
        }
fi

echo "Backup and replace system cuse.ko..."
if [ -f /boot/kernel/cuse.ko ] && [ ! -f /boot/kernel/cuse.ko.orig ]; then
        cp -p /boot/kernel/cuse.ko /boot/kernel/cuse.ko.orig
        echo "Created backup: /boot/kernel/cuse.ko.orig"
fi

cp -f "$KO" /boot/kernel/cuse.ko
chmod 444 /boot/kernel/cuse.ko
chown root:wheel /boot/kernel/cuse.ko
# -------------------------------------------------

kldload cuse
kldstat | grep cuse

if [ -x /usr/local/etc/rc.d/webcamd ]; then
        /usr/local/etc/rc.d/webcamd start 2>/dev/null || true
fi
echo "patched cuse installed and loaded permanently inside /boot/kernel/"
