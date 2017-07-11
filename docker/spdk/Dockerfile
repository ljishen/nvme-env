# VERSION 1.1

FROM phusion/baseimage:0.9.22
MAINTAINER Jianshen Liu <jliu120@ucsc.edu>

# See all prerequisites at https://github.com/spdk/spdk#prerequisites
RUN apt-get update \
    && apt-get install -y \
        gcc \
        g++ \
        make \
        libcunit1-dev \
        libaio-dev \
        libssl-dev \
        git \
        astyle \
        pep8 \
        lcov \
        clang

# Additional dependencies for NVMe over Fabrics
RUN apt-get install -y \
        libibverbs-dev \
        librdmacm-dev

# Dependencies require for RocksDB Integration
# Corresponding error message: "mkfs.xfs: not found", "perf: not found, gflags not installed."
RUN apt-get install -y \
        xfsprogs \
        linux-tools-common \
        libgflags-dev

# Dependencies for getting device information and load uio_pci_generic kernel module
RUN apt-get install -y \
        nvme-cli \
        pciutils \
        kmod

WORKDIR /root

# Clone the SPDK repo
RUN git clone https://github.com/spdk/spdk.git
RUN git -C /root/spdk submodule update --init

# Clone the RocksDB repo
RUN git clone -b spdk https://github.com/spdk/rocksdb.git

# Add run script
COPY run.sh .
RUN chmod +x run.sh

# Clean Up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["./run.sh"]
