# Dockerfile for Qemu NVMe Driver

## Usage

1. Pull the docker image
   ```bash
   docker pull ljishen/qemu-nvme
   ```
1. Entry the build environment
   ```bash
   docker run -ti \
        --privileged \
        -v `pwd`/img:/root/img \
        --entrypoint=/bin/bash \
        ljishen/qemu-nvme
   ```
1. Create a QEMU-compatible Debian system image
   ```bash
   IMG=/root/img/system.img
   DIR=/tmp/system
   ./qemu-img create $IMG 1G
   mkfs.ext2 $IMG
   mkdir $DIR
   mount -o loop $IMG $DIR
   debootstrap --arch amd64 stretch $DIR
   
   # configuring the root password
   chroot /tmp/system /usr/bin/passwd
   Enter new UNIX password:

   ...

   umount $DIR
   exit # exit the container
   ```
1. Create an empty file to hold the NVMe device.
   ```bash
   dd if=/dev/zero of=device/blknvme bs=1M count=1024
   ``` 
1. Boot the system with LightNVM-compatible device
   ```bash
   docker run -ti \
        --privileged \
        -v `pwd`/device:/root/device \
        -v `pwd`/img:/root/img \
        ljishen/qemu-nvme \
        -smp <number_of_cores_to_use> \
        -m <amount_of_memory>
   ```
   Example:
   ```bash
   docker run -ti \
        --privileged \
        -v `pwd`/device:/root/device \
        -v `pwd`/img:/root/img \
        ljishen/qemu-nvme \
        -smp 15 \
        -m 16G
   ```

## About

This work is based on [OpenChannelSSD/qemu-nvme](https://github.com/OpenChannelSSD/qemu-nvme).
