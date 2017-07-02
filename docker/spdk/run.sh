#!/usr/bin/env bash

set -e

cd /root/spdk

# Build SPDK and DPDK
./configure && make -j`nproc`

if [ $# -eq 0 ]; then
    LINUX_SRC=/usr/src/linux
    mkdir -p "$LINUX_SRC"

    # See http://wiki.qemu.org/Documentation/9psetup
    # for details of setting up VirtFS between the guest and host operating systems.
    mount -t 9p -o trans=virtio modules_mount "$LINUX_SRC" -oversion=9p2000.L,posixacl,cache=loose

    make -C "$LINUX_SRC" modules_install

    scripts/setup.sh && /bin/bash
else
    # Do whatever if the system already configured (with real NVMe device, uio_pci_generic module loaded).
    # Reference: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1473109
    scripts/setup.sh && "$@"
fi
