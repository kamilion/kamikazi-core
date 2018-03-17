#!/bin/bash
OLDDIR=${PWD}

echo "[kamikazi-build] Building Clean minilubuntu ISO from lubuntu-16.04-amd64.iso"
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
packages=$(awk '{print $1} ' 01-add-replacement-browser.synpkg)
apt-get install -y ${packages}
sleep 2
# Customizer will detect there is no kernel and install linux-image-generic.
echo "[kamikazi-build] Removing kernel packages."
apt-get purge -y linux-image*
sleep 2

echo "[kamikazi-build] Cleaning up..."
### Begin cleaning up the filesystem
# Remove this socket that causes unpacking squashfs to warn.
rm -f /run/synaptic.socket

echo "[kamikazi-build] Ready to Build ISO."
