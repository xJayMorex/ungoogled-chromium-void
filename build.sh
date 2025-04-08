#!/bin/bash

START=`date`
UGC=`pwd`

cd ..

[[ ! -d void-packages ]] && git clone --depth=1 https://github.com/void-linux/void-packages.git

cd void-packages
git reset --hard HEAD
git clean -f
git fetch
git pull

./xbps-src binary-bootstrap

cp -r $UGC/void-packages/srcpkgs/ungoogled-chromium srcpkgs/

XBPS_MAKEJOBS=`nproc` ./xbps-src pkg ungoogled-chromium

echo "Build start: $START"
echo "Build end: `date`"
