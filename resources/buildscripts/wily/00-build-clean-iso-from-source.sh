#!/bin/bash

echo "[kamikazi-deploy] Building Clean ISO from lubuntu-15.10-amd64.iso"

echo "[kamikazi-deploy] Replacing firefox with midori."
packages=$(awk '{print $1} ' 01-add-replacement-browser.synpkg)
apt-get install -y ${packages}
echo "[kamikazi-deploy] Removing packages."
packages=$(awk '{print $1} ' 02-purgelist.synpkg)
apt-get purge -y ${packages}
echo "[kamikazi-deploy] Adding base server packages."
packages=$(awk '{print $1} ' 03-addlist.synpkg)
echo ${packages}
apt-get install -y ${packages}
# Remove chronyd's pidfile.
rm -f /run/chronyd.pid
apt-get purge -y ntp
echo "[kamikazi-deploy] Adding python 2.x and 3.x development kit."
packages=$(awk '{print $1} ' 04-addlist-python-dev.synpkg)
echo ${packages}
apt-get install -y ${packages}
echo "[kamikazi-deploy] Adding Xen hypervisor and openvswitch packages."
packages=$(awk '{print $1} ' 05-addlist-xen.synpkg)
echo ${packages}
apt-get install -y ${packages}
echo "[kamikazi-deploy] Adding Ceph network block device packages."
packages=$(awk '{print $1} ' 06-addlist-ceph.synpkg)
echo ${packages}
apt-get install -y ${packages}

# Remove this socket that causes unpacking squashfs to warn.
rm -f /run/synaptic.socket

echo "[kamikazi-deploy] Ready to Build ISO."
