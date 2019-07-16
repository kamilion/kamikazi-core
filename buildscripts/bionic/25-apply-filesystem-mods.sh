#!/bin/bash
OLDDIR=${PWD}

sleep 2
echo "[kamikazi-build] Modifying systemd init defaults..."
### Alter Systemd configuration for kamikazi:
# Disable the GUI on boot to allow kamikazi-boot-late to start it later.
cd /lib/systemd/system
# Change the default boot target to multi-user.target from graphical.target
ln -sf multi-user.target default.target
# Disable NetworkMangler and ModemMangler...
systemctl disable NetworkManager ModemManager
# We don't have upstart's override files anymore, so we have to disable ceph.
systemctl disable ceph ceph-mon ceph-mds ceph-osd@.service ceph-disk@.service
# Disable snapd from starting up automatically.
systemctl disable snapd.service snapd.firstboot.service snapd.boot-ok.service
# Disable lxc from starting up automatically.
systemctl disable lxc-net.service lxc.service


sleep 2
echo "[kamikazi-build] Modifying nginx defaults..."
### Alter nginx configuration for kamikazi:
# Disable the default nginx site so autoconfig.conf can take over.
rm /etc/nginx/sites-enabled/default

sleep 2
echo "[kamikazi-build] Modifying casper liveiso defaults..."
### Alter Casper configuration for kamikazi:
rm /etc/ssh/ssh_host_*
# Disable trying to import a package pool from the cdrom media.
rm /usr/share/initramfs-tools/scripts/casper-bottom/41apt_cdrom
# Remove the built in hostname script that generates /etc/hosts
rm /usr/share/initramfs-tools/scripts/casper-bottom/18hostname
# This will be replaced with 18kamikazi_restore from our repo.
cd /home/git/kamikazi-core/resources/latest/mods/
cp -r usr/* /usr/
# Apply some additional udev rules for NICs.
cp -r lib/* /lib/
# Apply our modifications to /etc/, 18kamikazi_restore will populate over it.
cp -r etc/* /etc/
# Apply our modifications to /var/log
cp -r var/* /var/

# Enable supervisor in 16.04+...
systemctl enable supervisor
# Gee, it sure is nice to have the verb first.

# Force openssh-server to be reconfigured so we can answer the annoying UCF prompt.
echo ucf ucf/changeprompt_threeway select keep_current | debconf-set-selections
dpkg-reconfigure -fnoninteractive openssh-server
# Remove the keys that were just generated so they don't end up on the ISO.
rm -f /etc/ssh/ssh_host_*

cd ${OLDDIR}
echo "[kamikazi-build] Applied filesystem modifications."
apt-get update
echo "[kamikazi-build] Refreshed package cache."

