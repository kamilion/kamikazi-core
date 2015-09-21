#!/bin/bash
OLDDIR=${PWD}

echo "[kamikazi-build] Building Clean minilubuntu ISO from lubuntu-15.10-amd64.iso"
echo "[kamikazi-build] Replacing firefox with midori."
packages=$(awk '{print $1} ' 01-add-replacement-browser.synpkg)
apt-get install -y ${packages}
sleep 2
echo "[kamikazi-build] Removing packages."
packages=$(awk '{print $1} ' 02-purgelist.synpkg)
apt-get purge -y ${packages}
sleep 2

echo "[kamikazi-build] Cleaning up..."
### Begin cleaning up the filesystem
# Remove this socket that causes unpacking squashfs to warn.
rm -f /run/synaptic.socket

echo "[kamikazi-build] Ready to Build ISO."
