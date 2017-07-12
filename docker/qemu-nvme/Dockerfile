# VERSION 1.0

FROM phusion/baseimage:0.9.22
MAINTAINER Jianshen Liu <jliu120@ucsc.edu>

# Install all necessary packages for building QEMU
# See http://wiki.qemu.org/Hosts/Linux#Recommended_additional_packages
RUN apt-get update \
    && apt-get install -y \
        git-email \
        libaio-dev libbluetooth-dev libbrlapi-dev libbz2-dev \
        libcap-dev libcap-ng-dev libcurl4-gnutls-dev libgtk-3-dev \
        libibverbs-dev libjpeg8-dev libncurses5-dev libnuma-dev \
        librbd-dev librdmacm-dev \
        libsasl2-dev libsdl1.2-dev libseccomp-dev libsnappy-dev libssh2-1-dev \
        libvde-dev libvdeplug-dev libvte-dev libxen-dev liblzo2-dev \
        valgrind xfslibs-dev \
        libnfs-dev libiscsi-dev

RUN apt-get install -y bc

# Build the NVMe device emulation
WORKDIR /root
RUN git clone https://github.com/OpenChannelSSD/qemu-nvme.git 
WORKDIR /root/qemu-nvme
RUN ./configure --python=/usr/bin/python2 --enable-kvm --target-list=x86_64-softmmu --enable-debug --enable-linux-aio --prefix=$HOME/qemu-nvme
RUN make -j`nproc` && make install

WORKDIR /root

# Build the kernel with the LightNVM support.
# Currently the kernel release is 4.11.0-rc4+
RUN git clone https://github.com/OpenChannelSSD/linux.git
ENV LINUX_SRC /root/linux
RUN git -C $LINUX_SRC checkout for-next

## Add AUFS support to the kernel (for Docker)
## See http://aufs.sourceforge.net/
##     https://github.com/sfjro/aufs4-standalone/tree/aufs4.11.0-untested
##     http://fxlv.github.io/aufs-kernel-howto/
RUN git clone git://github.com/sfjro/aufs4-standalone.git
ENV AUFS_SRC /root/aufs4-standalone
###! CHECK if the kernel release changed
RUN git -C $AUFS_SRC checkout origin/aufs4.11.0-untested
WORKDIR $LINUX_SRC
RUN patch -p1 < $AUFS_SRC/aufs4-kbuild.patch
RUN patch -p1 < $AUFS_SRC/aufs4-base.patch
RUN patch -p1 < $AUFS_SRC/aufs4-mmap.patch
RUN cp -a $AUFS_SRC/Documentation/* Documentation/
RUN cp -a $AUFS_SRC/fs/* fs/
RUN cp -a $AUFS_SRC/include/uapi/linux/aufs_type.h include/uapi/linux/

## Build the kernel
### Generate kernel config
### See http://mgalgs.github.io/2015/05/16/how-to-build-a-custom-linux-kernel-for-qemu-2015-edition.html
###     https://github.com/moby/moby/blob/master/contrib/check-config.sh (Check docker-compatible kernel config)
COPY configs/.config .
RUN make -j`nproc`

## Build the perf program
RUN apt-get install -y \
        flex \
        bison \
        libelf-dev \
        libaudit-dev \
        libperl-dev \
        python-dev \
        libdw-dev \
        libunwind-dev \
        systemtap-sdt-dev \
        libssl-dev \
        liblzma-dev \
        libiberty-dev \
        binutils-dev
RUN make -C tools/perf/ -j`nproc`

# Clean Up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /root
COPY up .
RUN chmod +x up
ENTRYPOINT ["./up"]
