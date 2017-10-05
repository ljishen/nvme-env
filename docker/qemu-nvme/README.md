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

Install the KVM if you don't have the KVM modules. For Ubuntu, here is the documentation for [KVM/Installation](https://help.ubuntu.com/community/KVM/Installation).


## Usage

1. Download a Linux virtual machine image and place it into folder `img`

   For example, the most recent version of the 64-bit qcow2 image for Ubuntu 16.04 is [xenial-server-cloudimg-amd64-disk1.img](http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img). More Images can be found from [Get images](https://docs.openstack.org/image-guide/obtain-images.html).

1. Create a symbolic link `vm.img` pointed to the image file
   ```bash
   ln -s img/<image_file> img/vm.img
   ```

1. (Optional) Modify `img/my-user-data` and generate your `img/seed.img` using `cloud-localds`. `cloud-localds` is available in package `cloud-image-utils` if you are working on Ubuntu.
   ```bash
   cloud-localds img/my-seed.img img/my-user-data
   ```

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
       -m 8G
   ```
   * `-smp` Simulate an SMP system with n CPUs
   * `-m`  Set the RAM size for the guest system

   More options can be found at [QEMU Emulator User Documentation](http://download.qemu.org/qemu-doc.html).

1. Login the Linux system with your customized credential (password for the default user is `passw0rd`). Now you have the CNEX Labs LightNVM SDK - the LightNVM-compatible device working in the system.

   Install the [nvme-cli](https://github.com/linux-nvme/nvme-cli) command line tool to play with the NVMe device. Here are some examples:
   ```bash
   # Show namespace properties in human-readable format
   sudo nvme id-ns /dev/nvme0n1 -H

   # Retrieve SMART log
   sudo nvme smart-log /dev/nvme0n1

   # Get feature of the NVMe controller
   sudo nvme get-feature /dev/nvme0n1 -f 1 -H

   # Read some starting logical blocks to the stdout
   sudo nvme read /dev/nvme0n1 -z 128
   ```

### Running SPDK Applications

If you want to use SPDK in this QEMU system emulator, please make sure your CPU supports the [SSSE3](https://en.wikipedia.org/wiki/SSSE3) instruction set before moving forward.

1. Install Docker in the emulation system using
   ```bash
   curl -fsSL get.docker.com | sh
   ```
   You probably want to add your user to the docker group to avoid putting `sudo` before every `docker` command
   ```bash
   sudo usermod -aG docker $USER
   ```
   Then log out and log back in order to re-evaluated your group membership.

1. Setup the SPDK environment by running container
   ```bash
   docker run -ti \
       --privileged \
       --ipc host \
       -v /dev:/dev \
       -v /var/lib/docker/aufs/diff:/var/lib/docker/aufs/diff \
       ljishen/spdk
   ```
   Just wait until the source compiling finished.

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

1. For more details read the README of image [ljishen/spdk](https://github.com/ljishen/nvme-env/tree/master/docker/spdk).


## Troubleshooting

Look here if you have a problem while following the previous usage steps.

### Error: "docker: failed to register layer: Error processing tar file(exit status 1): write /usr/lib/x86_64-linux-gnu/libLLVM-3.8.so.1: no space left on device."

You may need to resize the image using [virt-* tools](https://docs.openstack.org/image-guide/modify-images.html#resize-an-image), then retry the failed docker command.


## Tested Environment

* Docker Version >= 1.12.5
* Ubuntu Release >= 12.04


## About

This work is based on [OpenChannelSSD/qemu-nvme](https://github.com/OpenChannelSSD/qemu-nvme).


## References

* Open-Channel Solid State Drives http://openchannelssd.readthedocs.io/en/latest/gettingstarted/
* Modify virtual machine image https://docs.openstack.org/image-guide/modify-images.html
* Storage Performance Development Kit (SPDK) Github https://github.com/spdk/spdk
* SPDK code sample - Hello World https://software.intel.com/en-us/articles/accelerating-your-nvme-drives-with-spdk
