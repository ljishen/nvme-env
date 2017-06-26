# Dockerfile for Qemu NVMe Driver

## Usage

- Download an install ISO to folder **os**, e.g. [Ubuntu 16.04.2 LTS](http://releases.ubuntu.com/16.04.2/ubuntu-16.04.2-desktop-amd64.iso)
- Pull the docker image
   ```bash
   docker pull ljishen/qemu-nvme
   ```
- Launch QEMU with NVMe device enabled
   ```bash
   docker run -d \
	--privileged \
	-p 5901:5901 \
	-v `pwd`/os:/root/os \
	ljishen/qemu-nvme \
	-smp <number of cores to use> \
	-m <amount of memory> \
	-cdrom <CD-ROM image>
   ```
   Example:
   ```bash
   docker run -d \
	--privileged \
	-p 5901:5901 \
	-v `pwd`/os:/root/os \
	ljishen/qemu-nvme \
	-smp 15 \
	-m 16G \
	-cdrom /root/os/ubuntu-16.04.2-desktop-amd64.iso
   ```
- Connect using your favorite VNC viewer to <host IP>:5901 

## About

This work is based on [OpenChannelSSD/qemu-nvme](https://github.com/OpenChannelSSD/qemu-nvme).
