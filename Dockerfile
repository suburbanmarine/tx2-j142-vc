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
RUN pbzip2 -d -c /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_src_J121.tar.bz2 | tar -x 
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

COPY --chown=buildbot:buildbot 0002-Reduced-image-size-limitation-from-width-32-to-4-and.patch /home/buildbot/0002-Reduced-image-size-limitation-from-width-32-to-4-and.patch

# Apply these kernel patches
WORKDIR /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_src
# kernel_common_32.3.1+
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_common_32.3.1+/0001-Added-cropping-position-left-top-to-sensor-image-pro.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_common_32.3.1+/0001-Added-.gitignore.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_common_32.3.1+/0001-Added-implementation-to-set-image-position-and-size-.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_common_32.3.1+/0002-Reduced-image-size-limitation-from-width-32-to-4-and.patch
# dt_camera_TX2_32.5.0+
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/dt_camera_TX2_32.5.0+/0001-Modified-tegra186-quill-p3310-1000-a00-00-base.dts-t.patch
# kernel_TX2_32.6.1+
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Added-controls-trigger_mode-flash_mode-and-black_lev.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Added-RAW8-grey-RAW10-y10-and-RAW12-y12-format-to-th.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Bugfix-in-destroy_buffer_table-.-When-the-capture_bu.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Commented-out-tegra186-quill-p3310-1000-a00-00-lc898.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Increased-tegra-channel-timeout.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0002-Changed-control-flash_mode-to-io_mode.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0003-Added-control-single_trigger-to-the-tegra-framework.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0003-Added-RAW14-y14-format-to-the-tegra-framework.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0003-Changed-Interrupt-Mask-for-csi4-to-emit-CRC-and-mul.patch
patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0004-Added-VC-MIPI-Driver-sources-to-Makefile.patch

# copy this kernel driver
# RUN cp -r /home/buildbot/vc_mipi_nvidia/src/driver/* /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_src/kernel/nvidia/drivers/media/i2c/

# apply this dtsi
# RUN cp /home/buildbot/vc_mipi_nvidia/src/devicetree/Auvidea_J20_TX2/tegra186-camera-vc-mipi-cam.dtsi /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_src/hardware/nvidia/platform/t18x/common/kernel-dts/t18x-common-modules/

# rebuild kernel? copy back to rootfs?

USER root
WORKDIR /home/buildbot

# flash tx2 emmc with
# ./flash.sh --no-root-check jetson-tx2-devkit mmcblk0p1