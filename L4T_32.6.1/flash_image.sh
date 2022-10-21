#!/usr/bin/env bash

pushd /home/buildbot/Linux_for_Tegra/
export USER=root
./flash.sh --no-root-check jetson-tx2-devkit mmcblk0p1

popd