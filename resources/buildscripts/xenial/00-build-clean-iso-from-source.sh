#!/bin/bash
OLDDIR=${PWD}

echo "[kamikazi-build] Building Clean ISO from lubuntu-16.04-amd64.iso"
echo "[kamikazi-build] Replacing firefox with qupzilla."
packages=$(awk '{print $1} ' 01-add-replacement-browser.synpkg)
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Removing application packages."
packages=$(awk '{print $1} ' 02-purgelist.synpkg)
apt-get purge -y ${packages}
sleep 2
echo "[kamikazi-build] Removing application library packages."
packages=$(awk '{print $1} ' 03-purgelist.synpkg)
apt-get purge -y ${packages}
sleep 2
echo "[kamikazi-build] Removing system library packages."
packages=$(awk '{print $1} ' 04-purgelist.synpkg)
apt-get purge -y ${packages}
sleep 2
echo "[kamikazi-build] Removing media packages."
packages=$(awk '{print $1} ' 05-purgelist.synpkg)
apt-get purge -y ${packages}
sleep 2
echo "[kamikazi-build] Adding base server packages."
packages=$(awk '{print $1} ' 13-addlist.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
# Remove chronyd's pidfile.
rm -f /run/chronyd.pid
apt-get purge -y ntp
echo "[kamikazi-build] Adding python 2.x and 3.x development kit."
packages=$(awk '{print $1} ' 14-addlist-python-dev.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Adding Xen hypervisor and openvswitch packages."
packages=$(awk '{print $1} ' 15-addlist-xen.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Adding Ceph network block device packages."
packages=$(awk '{print $1} ' 16-addlist-ceph.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Adding webserver packages."
packages=$(awk '{print $1} ' 17-addlist-nginx-server.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Adding open-vm-tools packages."
packages=$(awk '{print $1} ' 18-addlist-openvmtools.synpkg)
echo ${packages}
apt-get install -y ${packages}
sleep 2
# Purge the qt4-doc package, it's a hundred megs of incompressableness.
apt-get purge -y qt4-doc

sleep 2
# Trip off the next set of scripts.
./19-add-iso-customizer.sh
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
./35-add-python-stuff.sh
# uwsgi needs a systemd unit too. Filesystem mods must be applied first.
sleep 2
./40-build-pvgrub2-image.sh
# We have a pvgrub1 image from xen 4.5.0RC next to the hvmloader already.
# Might as well build a 64bit pvgrub2 image from grub-xen-bin while we're at it.

sleep 2
echo "[kamikazi-build] Cleaning up..."
### Begin cleaning up the filesystem
# Remove this socket that causes unpacking squashfs to warn.
rm -f /run/synaptic.socket

echo "[kamikazi-build] Ready to Build ISO."
