# SPDK (Storage Performance Development Kit) Docker Image

[![](https://images.microbadger.com/badges/image/ljishen/spdk.svg)](http://microbadger.com/images/ljishen/spdk)

Simple image built following the official [SPDK Documentation](https://github.com/spdk/spdk). This image intents to work with the NVMe device emulation image [ljishen/qemu-nvme](https://github.com/ljishen/nvme-env/tree/master/docker/qemu-nvme) while can be also used in an equipped system with real NVMe device.


## Usage

The container starts with configuring and compiling the SPDK source in order to aware the underlying system supports, e.g. SSSE3, RDRAND. Relying on the docker build may cause errors like **ERROR: This system does not support "XXXX".**

* When work with the NVMe device emulation image [ljishen/qemu-nvme](https://github.com/ljishen/nvme-env/tree/master/docker/qemu-nvme), start the container without argument
  ```bash
  docker run -ti \
      --privileged \
      -v /dev:/dev \
      ljishen/spdk
  ```

* If the system already configured with real NVMe devices
  ```bash
   docker run -ti \
       --privileged \
       -v /dev:/dev \
       ljishen/spdk \
       /bin/bash
  ```
