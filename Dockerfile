FROM ubuntu:18.04

RUN echo "Acquire::http::Proxy \"http://helios10g.lan:3142\";" > /etc/apt/apt.conf.d/02proxy

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	apt-utils            \
	&& apt-get clean

RUN apt-get update && apt-get purge -y \
	modemmanager            \
	&& apt-get clean

# Languages
RUN echo "locales locales/default_environment_locale select      en_US.UTF-8"       | debconf-set-selections
RUN echo "locales locales/locales_to_be_generated    multiselect en_US.UTF-8 UTF-8" | debconf-set-selections
RUN apt-get update && apt-get install -y \
	language-pack-en      \
	language-pack-en-base \
	locales               \
	&& apt-get clean
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Tools for interactive use
RUN apt-get update && apt-get install -y \
	gdebi               \
	iputils-ping        \
	iputils-tracepath   \
	rsync               \
	tzdata              \
	usbutils            \
	wget                \
	&& apt-get clean

RUN apt-get update && apt-get install -y \
	pbzip2              \
	pigz                \
	&& apt-get clean

# C dev tools
RUN apt-get update && apt-get install -y \
	build-essential      \
	cmake                \
	git                  \
	&& apt-get clean

# NVIDIA deps
RUN apt-get update && apt-get install -y \
	binfmt-support        \
	cpio                  \
	python                \
	python3               \
	qemu-user-static      \
	&& apt-get clean

RUN groupadd buildbot && useradd --no-log-init --create-home --home-dir /home/buildbot -g buildbot -s /bin/bash buildbot
RUN usermod -a -G dialout buildbot

USER buildbot
WORKDIR /home/buildbot

COPY --chown=buildbot:buildbot Jetpack_4_6_TX2_J121_J142_J143.tar.bz2 /home/buildbot/
COPY --chown=buildbot:buildbot tegra_linux_sample-root-filesystem_r32.6.1_aarch64.tbz2 /home/buildbot/
COPY --chown=buildbot:buildbot jetson_linux_r32.6.1_aarch64.tbz2 /home/buildbot/

# L4T base
RUN pbzip2 -d -c /home/buildbot/jetson_linux_r32.6.1_aarch64.tbz2 | tar -x 

# L4T sample rootfs
USER root
WORKDIR /home/buildbot/Linux_for_Tegra/rootfs
RUN pbzip2 -d -c /home/buildbot/tegra_linux_sample-root-filesystem_r32.6.1_aarch64.tbz2 | tar -x

# auvidea J142 patches
RUN mkdir /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143
WORKDIR /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143
RUN pbzip2 -d -c /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143.tar.bz2 | tar -x 
RUN pbzip2 -d -c /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_out.tar.bz2 | tar -x 
RUN cp -r /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_out/* /home/buildbot/Linux_for_Tegra/

USER root
WORKDIR /home/buildbot/Linux_for_Tegra
RUN ./apply_binaries.sh

# VC camera drivers
USER buildbot
WORKDIR /home/buildbot
RUN git clone https://github.com/VC-MIPI-modules/vc_mipi_nvidia.git
WORKDIR /home/buildbot/vc_mipi_nvidia
RUN git checkout v0.12.3


USER root
WORKDIR /home/buildbot

# flash tx2 emmc with
# ./flash.sh --no-root-check jetson-tx2 mmcblk0p1