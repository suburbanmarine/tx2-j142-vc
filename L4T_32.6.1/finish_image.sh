#!/usr/bin/env bash

# set -x
# trap read debug

# trap 'exit -1' err

pushd /home/buildbot/Linux_for_Tegra

# local caching proxy server
echo "Acquire::http::Proxy  \"http://helios.lan:3142\";" > /home/buildbot/Linux_for_Tegra/rootfs/etc/apt/apt.conf.d/02proxy
echo "Acquire::https::Proxy \"http://helios.lan:3142\";" >> /home/buildbot/Linux_for_Tegra/rootfs/etc/apt/apt.conf.d/02proxy

mv /home/buildbot/Linux_for_Tegra/rootfs/etc/apt/sources.list.d/nvidia-l4t-apt-source.list $HOME/nvidia-l4t-apt-source.list

./tools/l4t_create_default_user.sh -u mbari -p mbari -n tx2-imx183 --accept-license

mount --bind /run /home/buildbot/Linux_for_Tegra/rootfs/run
mount --bind /dev /home/buildbot/Linux_for_Tegra/rootfs/dev
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "mv /etc/resolv.conf /etc/resolv.conf.bak"
cp /etc/resolv.conf /home/buildbot/Linux_for_Tegra/rootfs/etc/resolv.conf

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari dialout"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari i2c"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari gpio"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get update"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install \\
	ca-certificates \\
	dnsutils        \\
	ethtool         \\
	gdebi           \\
	gpiod           \\
	i2c-tools       \\
	iperf           \\
	iperf3          \\
	lbzip2          \\
	minicom         \\
	nano            \\
	net-tools       \\
	netcat-openbsd  \\
	pigz            \\
	rsync           \\
	v4l-utils       \\
	wget            \\
	&& apt-get clean"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install build-essential cmake git"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install \\
	google-mock              \\
	googletest               \\
	gtk-doc-tools            \\
	libboost-all-dev         \\
	libelf-dev               \\
	libfcgi-dev              \\
	libgpiod-dev             \\
	libgrpc++-dev            \\
	libgrpc-dev              \\
	libgstreamermm-1.0-dev   \\
	libgstrtspserver-1.0-dev \\
	libi2c-dev               \\
	libopencv-core-dev       \\
	libopencv-highgui-dev    \\
	libopencv-imgcodecs-dev  \\
	libopencv-imgproc-dev    \\
	libprotobuf-c-dev        \\
	libprotobuf-dev          \\
	libprotoc-dev            \\
	libuvc-dev               \\
	libzmq3-dev              \\
	libzmqpp-dev             \\
	protobuf-c-compiler      \\
	protobuf-compiler        \\
	protobuf-compiler-grpc   \\
	rapidjson-dev            \\
	&& apt-get clean"

# fix module link
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "rm /lib/modules/4.9.253-tegra/build"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "ln -s /usr/src/linux-headers-4.9.253-tegra-ubuntu18.04_aarch64/kernel-4.9 /lib/modules/4.9.253-tegra/build"

chroot /home/buildbot/Linux_for_Tegra/rootfs/home/mbari /bin/bash -c "apt-get -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gtk-doc-tools"
chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari && export HOME=/home/mbari && git clone https://github.com/RidgeRun/gst-interpipe.git"
chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/gst-interpipe && export HOME=/home/mbari && git checkout v1.1.8"
chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/gst-interpipe && ./autogen.sh --libdir /usr/lib/aarch64-linux-gnu/"
chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/gst-interpipe && make -j`nproc`"
chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/gst-interpipe && make check"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/gst-interpipe && make install"

chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari     && export HOME=/home/mbari && git clone https://github.com/ZeroCM/zcm.git"
chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/zcm && ./waf configure --use-inproc --use-ipc --use-udpm --use-zmq --use-elf"
chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/zcm && ./waf build -j`nproc`"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/zcm && ./waf install"

chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari && export HOME=/home/mbari && git clone https://github.com/suburbanmarine/opaleye.git"
chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/opaleye && export HOME=/home/mbari && git submodule init"
chroot --userspec=+1000:+1000 /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "cd /home/mbari/opaleye && export HOME=/home/mbari && git submodule update"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "mv /etc/resolv.conf.bak /etc/resolv.conf"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c  "rm /etc/apt/apt.conf.d/02proxy"

mv $HOME/nvidia-l4t-apt-source.list /home/buildbot/Linux_for_Tegra/rootfs/etc/apt/sources.list.d/nvidia-l4t-apt-source.list

popd
