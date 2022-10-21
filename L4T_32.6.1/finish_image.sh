#!/usr/bin/env bash

pushd /home/buildbot/Linux_for_Tegra
./tools/l4t_create_default_user.sh -u mbari -p mbari -n tx2-imx183 --accept-license

mount --bind /run /home/buildbot/Linux_for_Tegra/rootfs/run
mount --bind /dev /home/buildbot/Linux_for_Tegra/rootfs/dev
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "mv /etc/resolv.conf /etc/resolv.conf.bak"
cp /etc/resolv.conf /home/buildbot/Linux_for_Tegra/rootfs/etc/resolv.conf
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get update"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install dnsutils minicom nano iperf iperf3 netcat-openbsd"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "apt-get -y install v4l-utils"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari dialout"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari i2c"
chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "adduser mbari gpio"

chroot /home/buildbot/Linux_for_Tegra/rootfs /bin/bash -c "mv /etc/resolv.conf.bak /etc/resolv.conf"
popd
