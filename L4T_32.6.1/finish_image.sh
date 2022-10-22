#!/usr/bin/env bash

pushd /home/buildbot/Linux_for_Tegra
./tools/l4t_create_default_user.sh -u mbari -p mbari -n tx2-imx183 --accept-license

mount --bind /run /home/buildbot/Linux_for_Tegra/rootfs/run
mount --bind /dev /home/buildbot/Linux_for_Tegra/rootfs/dev
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "mv /etc/resolv.conf /etc/resolv.conf.bak"
cp /etc/resolv.conf /home/buildbot/Linux_for_Tegra/rootfs/etc/resolv.conf
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get update"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install dnsutils minicom nano iperf iperf3 netcat-openbsd"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install ethtool net-tools"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install i2c-tools"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install lbzip pigz"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install rsync wget"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install v4l-utils"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install ca-certificates"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install build-essential cmake git"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari dialout"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari i2c"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari gpio"

chroot /home/buildbot/Linux_for_Tegra/rootfs/home/mbari /bin/bash -c "apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gtk-doc-tools"
chroot --userspec=mbari:mbari /home/buildbot/Linux_for_Tegra/rootfs/home/mbari/gst-interpipe /bin/bash -c "git clone https://github.com/RidgeRun/gst-interpipe.git"
chroot --userspec=mbari:mbari /home/buildbot/Linux_for_Tegra/rootfs/home/mbari/gst-interpipe /bin/bash -c "git checkout v1.1.8"
chroot --userspec=mbari:mbari /home/buildbot/Linux_for_Tegra/rootfs/home/mbari/gst-interpipe /bin/bash -c "./autogen.sh --libdir /usr/lib/aarch64-linux-gnu/"
chroot --userspec=mbari:mbari /home/buildbot/Linux_for_Tegra/rootfs/home/mbari/gst-interpipe /bin/bash -c "make"
chroot --userspec=mbari:mbari /home/buildbot/Linux_for_Tegra/rootfs/home/mbari/gst-interpipe /bin/bash -c "make check"
chroot /home/buildbot/Linux_for_Tegra/rootfs/home/mbari/gst-interpipe /bin/bash -c "make install"

chroot /home/buildbot/Linux_for_Tegra/rootfs/home/mbari /bin/bash -c "apt-get -y install libboost-all-dev"
chroot /home/buildbot/Linux_for_Tegra/rootfs/home/mbari /bin/bash -c "apt-get -y install libgstreamermm-1.0-dev libgstrtspserver-1.0-dev"
chroot /home/buildbot/Linux_for_Tegra/rootfs/home/mbari /bin/bash -c "apt-get -y install libopencv-imgproc-dev libopencv-highgui-dev libopencv-imgcodecs-dev libopencv-core-dev"
chroot /home/buildbot/Linux_for_Tegra/rootfs/home/mbari /bin/bash -c "apt-get -y install googletest google-mock"
rapidjson-dev
chroot --userspec=mbari:mbari /home/buildbot/Linux_for_Tegra/rootfs/home/mbari /bin/bash -c "git clone https://github.com/suburbanmarine/opaleye.git"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "mv /etc/resolv.conf.bak /etc/resolv.conf"
popd
