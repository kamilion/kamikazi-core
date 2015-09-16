#!/bin/bash
OLDDIR=${PWD}

sleep 2
echo "[kamikazi-build] Modifying systemd init defaults..."
### Alter Systemd configuration for kamikazi:
# Disable the GUI on boot to allow kamikazi-boot-late to start it later.
cd /lib/systemd/system
# Change the default boot target to multi-user.target from graphical.target
ln -sf multi-user.target default.target

sleep 2
echo "[kamikazi-build] Modifying casper liveiso defaults..."
### Alter Casper configuration for kamikazi:
# Remove the built in hostname script that generates /etc/hosts
rm /usr/share/initramfs-tools/scripts/casper-bottom/18hostname
# This will be replaced with 18kamikazi_restore from our repo.
cd /home/git/kamikazi-core/resources/latest/mods/
cp -r usr/* /usr/
# Apply some additional udev rules for NICs.
cp -r lib/* /lib/
# Apply our modifications to /etc/, 18kamikazi_restore will populate over it.
cp -r etc/* /etc/
# Force the generated initramfs to be up to date.
update-initramfs -u

cd ${OLDDIR}
echo "[kamikazi-build] Applied filesystem modifications."
