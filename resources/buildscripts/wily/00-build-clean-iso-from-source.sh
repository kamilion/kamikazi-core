#!/bin/bash
OLDDIR=${PWD}

echo "[kamikazi-build] Building Clean ISO from lubuntu-15.10-amd64.iso"
echo "[kamikazi-build] Replacing firefox with midori."
packages=$(awk '{print $1} ' 01-add-replacement-browser.synpkg)
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Removing packages."
packages=$(awk '{print $1} ' 02-purgelist.synpkg)
apt-get purge -y ${packages}
sleep 2
echo "[kamikazi-build] Adding base server packages."
packages=$(awk '{print $1} ' 03-addlist.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
# Remove chronyd's pidfile.
rm -f /run/chronyd.pid
apt-get purge -y ntp
echo "[kamikazi-build] Adding python 2.x and 3.x development kit."
packages=$(awk '{print $1} ' 04-addlist-python-dev.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Adding Xen hypervisor and openvswitch packages."
packages=$(awk '{print $1} ' 05-addlist-xen.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Adding Ceph network block device packages."
packages=$(awk '{print $1} ' 06-addlist-ceph.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Adding open-vm-tools packages."
packages=$(awk '{print $1} ' 07-addlist-openvmtools.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
# Purge the qt4-doc package, it's a hundred megs of incompressableness.
apt-get purge -y qt4-doc

sleep 2
# Trip off the next set of scripts.
./10-add-iso-customizer.sh
sleep 2
./20-add-ppas.sh
sleep 2
./21-add-rethinkdb.sh
sleep 2
./25-apply-filesystem-mods.sh
sleep 2
./30-add-serf.sh
# Serf needs a systemd unit, it's in our filesystem mods, must be applied first.

sleep 2
echo "[kamikazi-build] Cleaning up..."
### Begin cleaning up the filesystem
# Remove this socket that causes unpacking squashfs to warn.
rm -f /run/synaptic.socket

echo "[kamikazi-build] Ready to Build ISO."
