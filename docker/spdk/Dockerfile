# VERSION 1.0

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
        clang \
        python-dev \
        pciutils \
        kmod

# Additional dependencies for NVMe over Fabrics
RUN apt-get install -y \
        libibverbs-dev \
        librdmacm-dev

WORKDIR /root
RUN git clone https://github.com/spdk/spdk.git
RUN git -C /root/spdk submodule update --init

# Add run script
COPY run.sh .
RUN chmod +x run.sh

# Clean Up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["./run.sh"]
