#!/bin/sh
MMC=$1
mkdir -p mmc
mount ${MMC}2 mmc && mount ${MMC}1 mmc/boot
