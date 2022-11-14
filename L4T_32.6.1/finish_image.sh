#!/usr/bin/env bash

pushd /home/buildbot/Linux_for_Tegra
./tools/l4t_create_default_user.sh -u mbari -p mbari -n tx2-imx183 --accept-license

mount --bind /run /home/buildbot/Linux_for_Tegra/rootfs/run
mount --bind /dev /home/buildbot/Linux_for_Tegra/rootfs/dev
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "mv /etc/resolv.conf /etc/resolv.conf.bak"
cp /etc/resolv.conf /home/buildbot/Linux_for_Tegra/rootfs/etc/resolv.conf

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari dialout"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari i2c"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari gpio"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get update"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install dnsutils minicom nano iperf iperf3 netcat-openbsd"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install ethtool net-tools"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install i2c-tools gpiod"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install lbzip pigz"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install rsync wget gdebi"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install v4l-utils"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install ca-certificates"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install build-essential cmake git"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install gtk-doc-tools"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install libboost-all-dev libelf-dev"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install libuvc-dev"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install libfcgi-dev libzmq3-dev libzmqpp-dev rapidjson-dev"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install libi2c-dev libgpiod-dev"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install libgstreamermm-1.0-dev libgstrtspserver-1.0-dev"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install libopencv-imgproc-dev libopencv-highgui-dev libopencv-imgcodecs-dev libopencv-core-dev"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install googletest google-mock"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install libprotobuf-dev libprotobuf-c-dev libprotoc-dev protobuf-compiler protobuf-c-compiler protobuf-compiler-grpc libgrpc-dev libgrpc++-dev"

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

popd
