#!/bin/sh

MMC=mmc
STAGE_PRIV=staging/priv
STAGE_COMMON=staging/common

[ ! -d $STAGE_PRIV ] && echo "You must run 'stage.sh' before installing." && exit

enable_sv(){
    [ ! -L "$MMC/etc/runit/runsvdir/default/$1" ] && ln -s "/etc/sv/$1" "$MMC/etc/runit/runsvdir/default/"
}

disable_sv(){
    rm -f "$MMC/etc/runit/runsvdir/default/$1"
}

# setup script
install -o root -g root -m 0755 setup.sh $MMC/root/

# raspi config.txt
install -o root -g root -m 0644 $STAGE_COMMON/boot/config.txt $MMC/boot/

# tty
enable_sv agetty-ttyAMA0

# rc.local
install -o root -g root -m 0644 $STAGE_COMMON/etc/rc.local $MMC/etc/

# kernel modules
install -o root -g root -m 0755 -d $MMC/etc/modules-load.d
install -o root -g root -m 0644 $STAGE_COMMON/etc/modules-load.d/* $MMC/etc/modules-load.d/

# add chrony user/group with uid/gid = 998
install -o root -g root -m 0644 $STAGE_COMMON/etc/passwd $MMC/etc/
install -o root -g root -m 0644 $STAGE_COMMON/etc/group $MMC/etc/

# enable ntp (no hwclock)
enable_sv ntpd
install -o 998 -g 998 -m 0755 -d /var/log/chrony
install -o 998 -g 998 -m 0755 -d /var/lib/chrony
install -o root -g root -m 0644 $STAGE_COMMON/etc/chrony.conf $MMC/etc/

# premptively enable rng-tools daemon
enable_sv rngd

# dhcp
install -o root -g root -m 0644 $STAGE_PRIV/etc/dhcpcd.conf $MMC/etc/
enable_sv dhcpcd

# wpa_supplicant
if [ -f $STAGE_PRIV/etc/wpa_supplicant/wpa_supplicant.conf ]; then
    install -o root -g root -m 0755 -d $MMC/etc/wpa_supplicant
    install -o root -g root -m 0644 $STAGE_PRIV/etc/wpa_supplicant/wpa_supplicant.conf $MMC/etc/wpa_supplicant/
    enable_sv wpa_supplicant
else
    rm -rf $MMC/etc/wpa_supplicant
    disable_sv wpa_supplicant
fi

# ssh
install -o root -g root -m 0755 -d $MMC/etc/ssh/
install -o root -g root -m 0600 $STAGE_PRIV/etc/ssh/ssh_host_* $MMC/etc/ssh/

if [ -f $STAGE_PRIV/root/.ssh/authorized_keys ]; then
    install -o root -g root -m 0700 -d $MMC/root/.ssh
    install -o root -g root -m 0600 $STAGE_PRIV/root/.ssh/authorized_keys $MMC/root/.ssh/
fi

enable_sv sshd

# zsh config
install -o root -g root -m 0644 $STAGE_COMMON/root/.zshrc $MMC/root/
