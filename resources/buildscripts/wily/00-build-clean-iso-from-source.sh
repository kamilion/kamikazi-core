#!/bin/bash

echo "[kamikazi-build] Building Clean ISO from lubuntu-15.10-amd64.iso"

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


# Remove this socket that causes unpacking squashfs to warn.
rm -f /run/synaptic.socket

# Change the default boot target to multi-user.target from graphical.target
cd /lib/systemd/system
ln -sf multi-user.target default.target

# Apply our inner filesystem modifications.
cd /home/git/kamikazi-core/resources/latest/mods/
cp -r usr/* /usr/
cp -r lib/* /lib/
cp -r etc/* /etc/

# Force the generated initramfs to be up to date.
update-initramfs -u

echo "[kamikazi-build] Ready to Build ISO."
