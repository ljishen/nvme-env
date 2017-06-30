# NVMe Emulator for SPDK in Docker

This work puts the [vagrant environment](https://github.com/spdk/spdk/blob/master/scripts/vagrant/README.md) configured for project Storage Performance Development Kit (SPDK) into a docker container.

## Usage

1. Install the kernel headers on Ubuntu or Debian Linux
   ```bash
   sudo apt-get install linux-headers-$(uname -r)
   ```

1. Launch the VM
   ```bash
   docker run -ti \
        --privileged \
        --net host \
        -v /usr/src:/usr/src \
        -v /lib/modules:/lib/modules \
        ljishen/spdk-vagrant
   ```

1. Now you can try the NVMe sample application "Hello World" as mentioned in the [doc](https://github.com/spdk/spdk/blob/master/scripts/vagrant/README.md#hello-world)
   ```bash
   Welcome to Ubuntu 16.04 LTS (GNU/Linux 4.4.0-21-generic x86_64)

    * Documentation:  https://help.ubuntu.com/
   vagrant@localhost:~$ lspci | grep "Non-Volatile"
   00:0e.0 Non-Volatile memory controller: InnoTek Systemberatung GmbH Device 4e56

   vagrant@localhost:~$ sudo /spdk/examples/nvme/hello_world/hello_world
   Starting DPDK 17.05.0 initialization...
   [ DPDK EAL parameters: hello_world -c 0x1 --file-prefix=spdk0 --base-virtaddr=0x1000000000 --proc-type=auto ]
   EAL: Detected 4 lcore(s)
   EAL: Auto-detected process type: PRIMARY
   EAL: Probing VFIO support...
   Initializing NVMe Controllers
   EAL: PCI device 0000:00:0e.0 on NUMA socket 0
   EAL:   probe driver: 80ee:4e56 spdk_nvme
   Attaching to 0000:00:0e.0
   Attached to 0000:00:0e.0
   Using controller ORCL-VBOX-NVME-VER12 (VB1234-56789        ) with 1 namespaces.
     Namespace ID: 1 size: 1GB
   Initialization complete.
   Hello world!
   ```


## VM Configuration
By default, the VM boots with 4GM memory and 2 virtual CPU. Do the following if you want to change the default resource configuration

1. Launch the container with **bash**
   ```bash
    docker run -ti \
        --privileged \
        --net host \
        -v /usr/src:/usr/src \
        -v /lib/modules:/lib/modules \
        ljishen/spdk-vagrant \
        /bin/bash
   ```

1. Edit the file `scripts/vagrant/env.sh` to change the value of `SPDK_VAGRANT_VMCPU` or `SPDK_VAGRANT_VMRAM`, then save and exit.

1. Run `/root/up.sh` to launch the VM.
