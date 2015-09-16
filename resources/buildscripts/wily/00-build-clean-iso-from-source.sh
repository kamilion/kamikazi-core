#!/bin/bash

echo "[kamikazi-build] Building Clean ISO from lubuntu-15.10-amd64.iso"
apt-get autoremove -y
echo "[kamikazi-build] Replacing firefox with midori."
packages=$(awk '{print $1} ' 01-add-replacement-browser.synpkg)
apt-get install -y ${packages}
echo "[kamikazi-build] Removing packages."
packages=$(awk '{print $1} ' 02-purgelist.synpkg)
apt-get purge -y ${packages}
echo "[kamikazi-build] Adding base server packages."
packages=$(awk '{print $1} ' 03-addlist.synpkg)
echo ${packages}
apt-get install -y ${packages}
# Remove chronyd's pidfile.
rm -f /run/chronyd.pid
apt-get purge -y ntp
echo "[kamikazi-build] Adding python 2.x and 3.x development kit."
packages=$(awk '{print $1} ' 04-addlist-python-dev.synpkg)
echo ${packages}
apt-get install -y ${packages}
echo "[kamikazi-build] Adding Xen hypervisor and openvswitch packages."
packages=$(awk '{print $1} ' 05-addlist-xen.synpkg)
echo ${packages}
apt-get install -y ${packages}
echo "[kamikazi-build] Adding Ceph network block device packages."
packages=$(awk '{print $1} ' 06-addlist-ceph.synpkg)
echo ${packages}
apt-get install -y ${packages}
echo "[kamikazi-build] Adding open-vm-tools packages."
packages=$(awk '{print $1} ' 07-addlist-openvmtools.synpkg)
echo ${packages}
apt-get install -y ${packages}
# Purge the qt4-doc package, it's a hundred megs of incompressableness.
apt-get purge -y qt4-doc

# Trip off the next set of scripts.
./10-add-iso-customizer.sh
./12-add-serf.sh
./15-add-ppas.sh

echo "[kamikazi-build] Modifying systemd init defaults..."
### Alter Systemd configuration for kamikazi:
# Disable the GUI on boot to allow kamikazi-boot-late to start it later.
cd /lib/systemd/system
# Change the default boot target to multi-user.target from graphical.target
ln -sf multi-user.target default.target

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

echo "[kamikazi-build] Cleaning up..."
### Begin cleaning up the filesystem
# Remove this socket that causes unpacking squashfs to warn.
rm -f /run/synaptic.socket

echo "[kamikazi-build] Ready to Build ISO."
