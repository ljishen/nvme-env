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

RUN apt-get install -y vnc4server

WORKDIR /root
RUN git clone https://github.com/OpenChannelSSD/qemu-nvme.git 

WORKDIR /root/qemu-nvme
RUN ./configure --python=/usr/bin/python2 --enable-kvm --target-list=x86_64-softmmu --enable-debug --enable-linux-aio --prefix=$HOME/qemu-nvme
RUN make -j`nproc` && make install

WORKDIR /root/qemu-nvme/bin
COPY configs/test.qcow2 /root/qemu-nvme/bin/

EXPOSE 5901

ENTRYPOINT ["./qemu-system-x86_64", \
	    "-cpu", "host", \
	    "-enable-kvm", \
            "-drive", "file=test.qcow2,if=none,id=lightnvme", \
            "-device", "nvme,drive=lightnvme,serial=deadbeef,lver=1,lba_index=3,nlbaf=5,namespaces=1", \
            "-vga", "vmware", \
            "-vnc", ":1"]
