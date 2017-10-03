# VERSION 1.2

FROM phusion/baseimage:0.9.22
MAINTAINER Jianshen Liu <jliu120@ucsc.edu>

## FIXED: invoke-rc.d: could not determine current runlevel (https://github.com/Microsoft/omi/issues/317)
ENV RUNLEVEL 1
## FIXED: invoke-rc.d: policy-rc.d denied execution of start. (https://github.com/Microsoft/omi/issues/317)
RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

RUN apt-get update \
    && apt-get install -y \
        wget \
        git

WORKDIR /root
RUN git clone https://github.com/spdk/spdk.git
RUN git -C /root/spdk submodule update --init

ENV VAGRANT_VER 2.0.0
RUN wget https://releases.hashicorp.com/vagrant/${VAGRANT_VER}/vagrant_${VAGRANT_VER}_x86_64.deb
RUN dpkg -i vagrant_${VAGRANT_VER}_x86_64.deb
RUN rm -f vagrant_${VAGRANT_VER}_x86_64.deb

# Install VirtualBox
## FIXED: /usr/lib/virtualbox/vboxdrv.sh: 205: /usr/lib/virtualbox/vboxdrv.sh: cannot create /etc/udev/rules.d/60-vboxdrv.rules: Directory nonexistent
RUN mkdir -p /etc/udev/rules.d

##! Check code name of the base image
RUN echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" > /etc/apt/sources.list.d/virtualbox.list
RUN wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - && \
        wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
RUN apt-get update

## Use "yes" to cancel GRUB installation
RUN yes | apt-get install -y virtualbox-5.1

# Install VirtualBox extension pack
ENV EXT_PACK Oracle_VM_VirtualBox_Extension_Pack-5.1.28-117968.vbox-extpack
RUN wget http://download.virtualbox.org/virtualbox/5.1.28/$EXT_PACK
RUN VBoxManage extpack install \
        --accept-license=715c7246dc0f779ceab39446812362b2f9bf64a55ed5d3a905f053cfab36da9e $EXT_PACK
RUN rm -f $EXT_PACK

# Add bootstrap script
RUN mkdir /root/bin
COPY shell up /root/bin/
RUN chmod +x /root/bin/shell /root/bin/up
ENV PATH /root/bin:$PATH

# Clean Up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /root/spdk/scripts/vagrant
CMD ["up"]
