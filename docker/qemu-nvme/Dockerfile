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
        libnfs-dev libiscsi-dev \
        qemu-kvm

RUN apt-get install -y \
        bc \
        debootstrap

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
RUN patch -p1 < $AUFS_SRC/aufs4-standalone.patch
RUN cp -a $AUFS_SRC/Documentation/* Documentation/
RUN cp -a $AUFS_SRC/fs/* fs/
RUN cp -a $AUFS_SRC/include/uapi/linux/aufs_type.h include/uapi/linux/

## Build the kernel
### Generate kernel config
### General generation:      http://mgalgs.github.io/2015/05/16/how-to-build-a-custom-linux-kernel-for-qemu-2015-edition.html
### Specifically for Docker: https://blog.tutum.co/2013/12/14/enabling-the-user-namespace-in-ubuntu-13-10-saucy/
###                          http://blog.serverbuddies.com/enable-iptables-support-in-linux-kernel/
###     Check kernel config: https://github.com/moby/moby/blob/master/contrib/check-config.sh
COPY configs/.config .
RUN make -j`nproc`
### Kernel header files are needed when building aufs-util
RUN make headers_install

## Build aufs-util
WORKDIR /root
RUN git clone git://git.code.sf.net/p/aufs/aufs-util
WORKDIR /root/aufs-util
###! CHECK if the branch matches the nearest lower number of the kernel's minor version number.
RUN git checkout origin/aufs4.x-rcN
RUN make -j`nproc` && make install

WORKDIR /root/qemu-nvme/bin
ENTRYPOINT ["./qemu-system-x86_64", \
            "-enable-kvm", \
            "-cdrom", "/root/img/seed.img", \
            "-hda", "/root/img/vm.img", \
            "-append", "root=/dev/sda1 console=ttyS0", \
            "-kernel", "/root/linux/arch/x86_64/boot/bzImage", \
            "-drive", "file=/root/device/blknvme,if=none,id=mynvme", \
            "-device", "nvme,drive=mynvme,serial=deadbeef,lver=1,lba_index=3,nlbaf=5,namespaces=1,mdts=10", \
            "--nographic"]
