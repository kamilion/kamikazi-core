#!/bin/bash

echo "[kamikazi-deploy] Building Clean ISO from lubuntu-15.04-amd64.iso"

echo "[kamikazi-deploy] Replacing firefox with midori."
dpkg --set-selections < 01-add-replacement-browser.synpkg
apt-get -y dselect-upgrade
echo "[kamikazi-deploy] Removing packages."
dpkg --set-selections < 02-purgelist.synpkg
apt-get -y dselect-upgrade
echo "[kamikazi-deploy] Adding base server packages."
dpkg --set-selections < 03-addlist.synpkg
apt-get -y dselect-upgrade
# Remove chronyd's pidfile.
rm -f /run/chronyd.pid
echo "[kamikazi-deploy] Adding python 2.x and 3.x development kit."
dpkg --set-selections < 04-addlist-python-dev.synpkg
apt-get -y dselect-upgrade
echo "[kamikazi-deploy] Adding Xen hypervisor and openvswitch packages."
dpkg --set-selections < 05-addlist-xen.synpkg
apt-get -y dselect-upgrade
echo "[kamikazi-deploy] Adding Ceph network block device packages."
dpkg --set-selections < 06-addlist-ceph.synpkg
apt-get -y dselect-upgrade

# Remove this socket that causes unpacking squashfs to warn.
rm -f /run/synaptic.socket

echo "[kamikazi-deploy] Ready to Build ISO."