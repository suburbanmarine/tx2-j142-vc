#!/usr/bin/env bash

pushd /home/buildbot/Linux_for_Tegra
export USER=root
./flash.sh jetson-tx2 mmcblk0p1

popd