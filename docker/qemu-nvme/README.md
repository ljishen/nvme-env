# Dockerfile for Qemu NVMe Driver

## Usage

1. Download a Linux virtual machine image

   The most recent version of the 64-bit QCOW2 image for Ubuntu 16.04 is [xenial-server-cloudimg-amd64-disk1.img](http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img). More Images can be found from [Get images](https://docs.openstack.org/image-guide/obtain-images.html).

1. Create a symbolic link `vm.img` to the image file in folder `img`
   ```bash
   ln -s <image_file> img/vm.img
   ```

1. (Optional) Generate your `img/seed.img` using `cloud-localds` from package `cloud-image-utils`(Ubuntu)

   The cloud-config is fed by `cloud-init` ([doc](http://cloudinit.readthedocs.io/en/latest/topics/examples.html), [example](http://blog.dustinkirkland.com/2016/09/howto-launch-ubuntu-cloud-image-with.html)).

1. Pull the docker image
   ```bash
   docker pull ljishen/qemu-nvme
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

1. Login with your customized credential (default user `ubuntu` with password `passw0rd`)

## About

This work is based on [OpenChannelSSD/qemu-nvme](https://github.com/OpenChannelSSD/qemu-nvme).
