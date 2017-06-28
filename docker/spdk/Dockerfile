# VERSION 1.0

FROM phusion/baseimage:0.9.22
MAINTAINER Jianshen Liu <jliu120@ucsc.edu>

RUN apt-get update \
    && apt-get install -y \
        git \
        gcc \
        g++ \
        make \
        libcunit1-dev \
        libaio-dev \
        libssl-dev \
        python-dev \
        pciutils

# Additional dependencies for NVMe over Fabrics
RUN apt-get install -y \
        libibverbs-dev \
        librdmacm-dev

WORKDIR /root
RUN git clone https://github.com/spdk/spdk.git

WORKDIR /root/spdk
RUN git submodule update --init
RUN ./configure && make
