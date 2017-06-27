# Prototype Environment for NVMe

The NVMe device emulation code includes a LightNVM subsystem which works on QEMU.

NVMe devices and namespaces information
```bash
ubuntu@ubuntu:~$ sudo nvme list
Node             SN                   Model                                    Version  Namespace Usage                      Format           FW Rev
---------------- -------------------- ---------------------------------------- -------- --------- -------------------------- ---------------- --------
/dev/nvme0n1     deadbeef             QEMU NVMe Ctrl                           1.1      1           1.07  GB /   1.07  GB      4 KiB +  0 B   1.0
ubuntu@ubuntu:~$
ubuntu@ubuntu:~$ lspci
00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 02)
00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
00:01.1 IDE interface: Intel Corporation 82371SB PIIX3 IDE [Natoma/Triton II]
00:01.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 03)
00:02.0 VGA compatible controller: Cirrus Logic GD 5446
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 03)
00:04.0 Non-Volatile memory controller: CNEX Labs QEMU NVM Express LightNVM Controller
```

## Usage

First please make sure your kernel has the KVM modules loaded. Check you have the similar output as follows,

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

1. Download a Linux virtual machine image to folder `img`

   The most recent version of the 64-bit QCOW2 image for Ubuntu 16.04 is [xenial-server-cloudimg-amd64-disk1.img](http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img). More Images can be found from [Get images](https://docs.openstack.org/image-guide/obtain-images.html).

1. Create a symbolic link `vm.img` pointed to the image file
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

This work is based on [OpenChannelSSD/qemu-nvme](https://github.com/OpenChannelSSD/qemu-nvme). Check this Open-Channel Solid State Drives [Documentation](http://openchannelssd.readthedocs.io/en/latest/gettingstarted/) for more details.
