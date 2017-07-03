# VERSION 1.1

FROM phusion/baseimage:0.9.22
MAINTAINER Jianshen Liu <jliu120@ucsc.edu>

RUN apt-get update \
    && apt-get install -y \
        wget \
        git

WORKDIR /root
RUN git clone https://github.com/spdk/spdk.git
RUN git -C /root/spdk submodule update --init

ENV VAGRANT_VER 1.9.5
RUN wget https://releases.hashicorp.com/vagrant/1.9.5/vagrant_${VAGRANT_VER}_x86_64.deb
RUN dpkg -i vagrant_${VAGRANT_VER}_x86_64.deb
RUN rm -f vagrant_${VAGRANT_VER}_x86_64.deb

# Install VirtualBox
##! Check code name of the base image
RUN echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" > /etc/apt/sources.list.d/virtualbox.list
RUN wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - && \
        wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
RUN apt-get update \
    && apt-get install -y \
        virtualbox-5.1

# Install VirtualBox extension pack
ENV EXT_PACK Oracle_VM_VirtualBox_Extension_Pack-5.1.22-115126.vbox-extpack
RUN wget http://download.virtualbox.org/virtualbox/5.1.22/$EXT_PACK
RUN VBoxManage extpack install \
        --accept-license=715c7246dc0f779ceab39446812362b2f9bf64a55ed5d3a905f053cfab36da9e $EXT_PACK
RUN rm -f $EXT_PACK

# Add bootstrap script
COPY up.sh .
RUN chmod +x up.sh

# Clean Up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["./up.sh"]
