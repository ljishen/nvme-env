# VERSION 1.2

FROM phusion/baseimage:0.9.22
MAINTAINER Jianshen Liu <jliu120@ucsc.edu>

RUN apt-get update \
    && apt-get install -y \
        git \
        nvme-cli

# Dependencies required for running db_bench
# Relevant error message: "mkfs.xfs: not found", "gflags not installed."
RUN apt-get install -y \
        xfsprogs \
        libgflags-dev \
        sudo \
        time \
        libdw1 \
        libelf1 \
        libunwind8 \
        libslang2 \
        libpython2.7 \
        libnuma1

# Dependencies for getting device information and load uio_pci_generic kernel module
RUN apt-get install -y \
        pciutils \
        kmod

WORKDIR /root

# Clone the SPDK repo
RUN git clone https://github.com/spdk/spdk.git
RUN git -C /root/spdk submodule update --init

## Install dependencies for SPDK
RUN /root/spdk/scripts/pkgdep.sh

# Clone the RocksDB repo
RUN git clone -b spdk-v5.6.1 https://github.com/spdk/rocksdb.git

# Clean Up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add run script
COPY run .
RUN chmod +x run

ENTRYPOINT ["./run"]
