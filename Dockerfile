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
	iputils-ping        \
	iputils-tracepath   \
	manpages-dev        \
	manpages-posix      \
	manpages-posix-dev  \
	rsync               \
	tzdata              \
	usbutils            \
	wget                \
	xauth               \
	&& apt-get clean

RUN apt-get update && apt-get install -y \
	pbzip2              \
	pigz                \
	xz-utils            \
	&& apt-get clean

# C dev tools
RUN apt-get update && apt-get install -y \
	autoconf             \
	bc                   \
	bison                \
	build-essential      \
	cmake                \
	flex                 \
	gawk                 \
	git                  \
	libelf-dev           \
	libncurses-dev       \
	libssl-dev           \
	xxd                  \
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

COPY --chown=buildbot:buildbot Jetpack_4_6_TX2_J121_J142_J143.tar.bz2                   /home/buildbot/
COPY --chown=buildbot:buildbot tegra_linux_sample-root-filesystem_r32.6.1_aarch64.tbz2  /home/buildbot/
COPY --chown=buildbot:buildbot jetson_linux_r32.6.1_aarch64.tbz2                        /home/buildbot/
COPY --chown=buildbot:buildbot gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz /home/buildbot/

# L4T compiler
RUN xz --decompress --stdout /home/buildbot/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz | tar -x 

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

# VC camera drivers
USER buildbot
WORKDIR /home/buildbot
RUN git clone https://github.com/VC-MIPI-modules/vc_mipi_nvidia.git
WORKDIR /home/buildbot/vc_mipi_nvidia
RUN git checkout v0.12.3

# Apply these kernel patches
WORKDIR /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_src
# kernel_common_32.3.1+
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_common_32.3.1+/0001-Added-.gitignore.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_common_32.3.1+/0001-Added-cropping-position-left-top-to-sensor-image-pro.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_common_32.3.1+/0001-Added-implementation-to-set-image-position-and-size-.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_common_32.3.1+/0002-Reduced-image-size-limitation-from-width-32-to-4-and.patch
# kernel_TX2_32.6.1+
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Added-controls-trigger_mode-flash_mode-and-black_lev.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Added-RAW8-grey-RAW10-y10-and-RAW12-y12-format-to-th.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Bugfix-in-destroy_buffer_table-.-When-the-capture_bu.patch
# This is already commented out by auvidea
# RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Commented-out-tegra186-quill-p3310-1000-a00-00-lc898.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0001-Increased-tegra-channel-timeout.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0002-Changed-control-flash_mode-to-io_mode.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0003-Added-control-single_trigger-to-the-tegra-framework.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0003-Added-RAW14-y14-format-to-the-tegra-framework.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0003-Changed-Interrupt-Mask-for-csi4-to-emit-CRC-and-mul.patch
RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/kernel_TX2_32.6.1+/0004-Added-VC-MIPI-Driver-sources-to-Makefile.patch
# dt_camera_TX2_32.5.0+
# TODO - fix this and double check camera dts settings & J142 settings
# RUN patch -p1 < /home/buildbot/vc_mipi_nvidia/patch/dt_camera_TX2_32.5.0+/0001-Modified-tegra186-quill-p3310-1000-a00-00-base.dts-t.patch

# add this dtsi
RUN cp /home/buildbot/vc_mipi_nvidia/src/devicetree/Auvidea_J20_TX2/tegra186-camera-vc-mipi-cam.dtsi /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_src/hardware/nvidia/platform/t18x/common/kernel-dts/t18x-common-modules/

# copy this kernel driver
RUN cp -r /home/buildbot/vc_mipi_nvidia/src/driver/* /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_src/kernel/nvidia/drivers/media/i2c/

# rebuild kernel? copy back to rootfs?

# setup kernel build
RUN mkdir /home/buildbot/kernel_out
ENV CROSS_COMPILE_AARCH64_PATH=/home/buildbot/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu
ENV TEGRA_KERNEL_OUT=/home/buildbot/kernel_out
ENV CROSS_COMPILE=/home/buildbot/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
ENV LOCALVERSION=-tegra

# build kernel - https://docs.nvidia.com/jetson/archives/l4t-archived/l4t-3261/index.html#page/Tegra%20Linux%20Driver%20Package%20Development%20Guide/kernel_custom.html#
WORKDIR /home/buildbot/Jetpack_4_6_TX2_J121_J142_J143/kernel_src/kernel/kernel-4.9
RUN make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig
RUN make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j`nproc`
# package modules
RUN mkdir /home/buildbot/kernel_libs_out
RUN make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=/home/buildbot/kernel_libs_out
WORKDIR /home/buildbot/kernel_libs_out
RUN tar --owner root --group root -cjf /home/buildbot/kernel_supplements.tbz2 lib/modules

# install kernel & modules
# RUN cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image /home/buildbot/Linux_for_Tegra/kernel/Image
# RUN rm -r /home/buildbot/Linux_for_Tegra/kernel/dtb/*
# RUN cp -r $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/* /home/buildbot/Linux_for_Tegra/kernel/dtb/
# RUN cp /home/buildbot/kernel_supplements.tbz2 /home/buildbot/Linux_for_Tegra/kernel/kernel_supplements.tbz2

USER root
WORKDIR /home/buildbot/Linux_for_Tegra
RUN ./apply_binaries.sh

USER buildbot
WORKDIR /home/buildbot

# flash tx2 emmc with
# ./flash.sh --no-root-check jetson-tx2-devkit mmcblk0p1