#!/usr/bin/env bash

# See http://wiki.qemu.org/Documentation/9psetup#Starting_the_Guest_directly
# for details about enabling 9P sharing.

set -e

if [[ "$@" == -* ]]; then
    /root/qemu-nvme/bin/qemu-system-x86_64 \
        -enable-kvm \
        -cpu SandyBridge \
        -cdrom "/root/img/my-seed.img" \
        -hda "/root/img/vm.img" \
        -append "root=/dev/sda1 console=ttyS0" \
        -kernel "/root/linux/arch/x86_64/boot/bzImage" \
        -drive "file=/root/device/blknvme,if=none,id=mynvme" \
        -device "nvme,drive=mynvme,serial=deadbeef,lver=1,lba_index=3,nlbaf=5,namespaces=1,mdts=10" \
        -fsdev "local,id=modules_dev,path=/root/linux,security_model=none" \
        -device "virtio-9p-pci,fsdev=modules_dev,mount_tag=modules_mount" \
        --nographic \
        "$@"
else
    "$@"
fi
