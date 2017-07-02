# Prototype Environment for NVMe

[![Build Status](https://travis-ci.org/ljishen/nvme-env.svg?branch=master)](https://travis-ci.org/ljishen/nvme-env)
[![](https://images.microbadger.com/badges/image/ljishen/qemu-nvme.svg)](http://microbadger.com/images/ljishen/qemu-nvme)

The NVMe device emulation code includes a LightNVM subsystem which works on QEMU.

#### Information of the system emulator
```bash
ubuntu@ubuntu:~$ sudo nvme list
Node             SN                   Model                                    Version  Namespace Usage                      Format           FW Rev
---------------- -------------------- ---------------------------------------- -------- --------- -------------------------- ---------------- --------
/dev/nvme0n1     deadbeef             QEMU NVMe Ctrl                           1.1      1           1.07  GB /   1.07  GB      4 KiB +  0 B   1.0

ubuntu@ubuntu:~$ lspci | grep "Non-Volatile"
00:04.0 Non-Volatile memory controller: CNEX Labs QEMU NVM Express LightNVM Controller

ubuntu@ubuntu:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 16.04.2 LTS
Release:        16.04
Codename:       xenial

ubuntu@ubuntu:~$ ifconfig -s
Iface   MTU Met   RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
enp0s3     1500 0        48      0      0 0            53      0      0      0 BMRU
lo        65536 0       110      0      0 0           110      0      0      0 LRU
```

## Prerequisite

Please make sure your kernel has the KVM modules loaded. Check you have the similar output as follows,

For Intel processor
```bash
$ lsmod | grep kvm
kvm_intel             167936  0
kvm                   516096  1 kvm_intel
```

For AMD processor
```bash
$ lsmod | grep kvm
kvm_amd                61440  0
kvm                   512000  1 kvm_amd
```

## Usage

1. Download a Linux virtual machine image and place it into folder `img`

   For example, the most recent version of the 64-bit qcow2 image for Ubuntu 16.04 is [xenial-server-cloudimg-amd64-disk1.img](http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img). More Images can be found from [Get images](https://docs.openstack.org/image-guide/obtain-images.html).

1. Create a symbolic link `vm.img` pointed to the image file
   ```bash
   ln -s <image_file> img/vm.img
   ```

1. (Optional) Modify `img/my-user-data` and generate your `img/seed.img` using `cloud-localds`. `cloud-localds` is available in package `cloud-image-utils` if you are working on Ubuntu.

   The cloud-config is fed by `cloud-init` ([doc](http://cloudinit.readthedocs.io/en/latest/topics/examples.html), [example](http://blog.dustinkirkland.com/2016/09/howto-launch-ubuntu-cloud-image-with.html)).

1. Create an empty file to hold the NVMe device.
   ```bash
   dd if=/dev/zero of=device/blknvme bs=1M count=1024
   ```

1. Boot the QEMU Linux system
   ```bash
   docker run -ti \
        --privileged \
        -v `pwd`/device:/root/device \
        -v `pwd`/img:/root/img \
        ljishen/qemu-nvme \
        -smp 2 \
        -m 4G
   ```
   * `-smp` Simulate an SMP system with n CPUs
   * `-m`  Set the RAM size for the guest system

   More options can be found at [QEMU Emulator User Documentation](http://download.qemu.org/qemu-doc.html).

1. Login the Linux system with your customized credential (default user `ubuntu` with password `passw0rd`)

1. Install Docker in the emulation system using
   ```bash
   curl -sSL https://get.docker.com/ | sh
   ```
   You probably want to add your user to the docker group to avoid putting `sudo` before every `docker` command
   ```bash
   sudo usermod -aG docker $USER
   ```
   Then log out and log back in order to re-evaluated your group membership.

1. Setup the SPDK environment by running container
   ```bash
   docker run -ti --privileged -v /dev:/dev ljishen/spdk
   ```

1. Try any of the NVMe sample application in the SPDK repo. Here is the sample output from the "Hello World" application
   ```bash
   root@995b35de7a12:~/spdk# lspci | grep "Non-Volatile"
   00:04.0 Non-Volatile memory controller: CNEX Labs QEMU NVM Express LightNVM Controller

   root@995b35de7a12:~/spdk# examples/nvme/hello_world/hello_world
   Starting DPDK 17.05.0 initialization...
   [ DPDK EAL parameters: hello_world -c 0x1 --file-prefix=spdk0 --base-virtaddr=0x1000000000 --proc-type=auto ]
   EAL: Detected 15 lcore(s)
   EAL: Auto-detected process type: PRIMARY
   EAL: Probing VFIO support...
   EAL: WARNING: cpu flags constant_tsc=yes nonstop_tsc=no -> using unreliable clock cycles !
   Initializing NVMe Controllers
   EAL: PCI device 0000:00:04.0 on NUMA socket 0
   EAL:   probe driver: 1d1d:1f1f spdk_nvme
   Attaching to 0000:00:04.0
   Attached to 0000:00:04.0
   Using controller QEMU NVMe Ctrl       (deadbeef            ) with 1 namespaces.
   Namespace ID: 1 size: 1GB
   Initialization complete.
   Hello world!
   ```

## About

This work is based on [OpenChannelSSD/qemu-nvme](https://github.com/OpenChannelSSD/qemu-nvme). Check this Open-Channel Solid State Drives [Documentation](http://openchannelssd.readthedocs.io/en/latest/gettingstarted/) for more details.
