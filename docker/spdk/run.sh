#!/usr/bin/env bash

set -e

# Build SPDK and DPDK first
cd /root/spdk
./configure && make -j`nproc`

# Build the RocksDB
cd /root/rocksdb
make -j`nproc` db_bench SPDK_DIR=/root/spdk
mkdir /usr/local/etc/spdk/
cd /root/spdk
cp etc/spdk/rocksdb.conf.in /usr/local/etc/spdk/rocksdb.conf
scripts/gen_nvme.sh >> /usr/local/etc/spdk/rocksdb.conf

if [ $# -eq 0 ]; then
    LINUX_SRC=/usr/src/linux
    mkdir -p "$LINUX_SRC"

    # See http://wiki.qemu.org/Documentation/9psetup
    # for details of setting up VirtFS between the guest and host operating systems.
    mount -t 9p -o trans=virtio modules_mount "$LINUX_SRC" -oversion=9p2000.L,posixacl,cache=loose

    make -C "$LINUX_SRC" modules_install
fi

# By default this script allocates 2GB (1024 huge pages)
scripts/setup.sh

test/lib/blobfs/mkfs/mkfs /usr/local/etc/spdk/rocksdb.conf Nvme0n1

if [ $# -eq 0 ]; then
    /bin/bash
else
   # Do whatever if the system already configured (with real NVMe device, uio_pci_generic module loaded).
   # Also see: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1473109
   "$@"
fi
