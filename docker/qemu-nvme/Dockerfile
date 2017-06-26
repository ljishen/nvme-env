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

# Build the LightNVM kernel
WORKDIR /root
RUN git clone https://github.com/OpenChannelSSD/linux.git

WORKDIR /root/linux
RUN git checkout for-next
COPY configs/.config .
RUN make -j`nproc`

WORKDIR /root/qemu-nvme/bin

ENTRYPOINT ["./qemu-system-x86_64", \
            "-enable-kvm", \
            "-hda", "/root/img/system.img", \
            "-append", "root=/dev/sda console=ttyS0", \
            "-kernel", "/root/linux/arch/x86_64/boot/bzImage", \
            "-drive", "file=/root/device/blknvme,if=none,id=lightnvme", \
            "-device", "nvme,drive=lightnvme,serial=deadbeef,lver=1,lba_index=3,nlbaf=5,namespaces=1,mdts=10", \
            "--nographic"]
