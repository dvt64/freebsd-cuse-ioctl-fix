# freebsd-cuse-ioctl-fix

cuse kernel module patch to fix gamepad rumble (vibration) and force feedback on FreeBSD via CUSE / webcamd.

## Requirements
* FreeBSD kernel sources installed in `/usr/src`

## Installation

1. **Build the patched module:**
   ```bash
   ./build.sh
   ```

2. **Install and load permanently:**
   ```bash
   sudo ./load_and_install.sh
   ```

