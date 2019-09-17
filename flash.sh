#!/bin/sh
MMC=$1
IMAGE=$(ls -1 void-rpi-musl-*.img | sort -n | tail -1)

[ -z "$IMAGE" ] && echo "No void-rpi-musl-*.img" && exit

pv "$IMAGE" | dd of=$MMC

echo ", +" | sfdisk -N 2 "$MMC"
e2fsck -f "${MMC}2"
resize2fs "${MMC}2"
