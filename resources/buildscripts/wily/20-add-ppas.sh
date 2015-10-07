#!/bin/bash

echo "[kamikazi-build] Injecting PPAs and packages."
apt-get autoremove --purge -y

echo "[kamikazi-build] Injecting x2go repository"
#wajig addrepo ppa:kamilion/x2go-kamikazi
add-apt-repository -y -u ppa:kamilion/x2go-kamikazi
packages="x2goserver x2golxdebindings x2godesktopsharing pyhoca-gui x2goclient"
apt-get install -y ${packages}

echo "[kamikazi-build] Injecting midori repository"
add-apt-repository -y -u ppa:midori/ppa
packages="midori"
apt-get install -y ${packages}

echo "[kamikazi-build] Injecting whdd repository"
add-apt-repository -y -u ppa:kamilion/whdd
packages="whdd"
apt-get install -y ${packages}

# Wily currently ships btrfs-tools 4.0.0 -- there's been lots of fixes
# since april when it was released, including a crashfix for subvol list.
echo "[kamikazi-build] Injecting btrfs-tools 4.2 repository"
add-apt-repository -y -u ppa:nemh/btrfs
packages="btrfs-tools"
apt-get install -y ${packages}

echo "[kamikazi-build] PPA injection complete."
