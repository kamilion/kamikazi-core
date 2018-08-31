#!/bin/bash

echo "[kamikazi-build] Injecting PPAs and packages."
apt-get autoremove --purge -y

echo "[kamikazi-build] Injecting x2go repository"
# Development Repo
#wajig addrepo ppa:kamilion/x2go-kamikazi
# Stable Repo
#add-apt-repository -y -u ppa:x2go/stable
# As of bionic, x2go's in universe.
packages="x2goserver x2goserver-fmbindings pyhoca-cli x2goclient"
apt-get install -y ${packages}

#echo "[kamikazi-build] Injecting whdd repository"
#add-apt-repository -y -u ppa:kamilion/whdd
#packages="whdd"
#apt-get install -y ${packages}

echo "[kamikazi-build] Injecting wireguard repository"
add-apt-repository -y -u ppa:wireguard/wireguard
packages="wireguard-dkms wireguard-tools"
apt-get install -y ${packages}

echo "[kamikazi-build] PPA injection complete."
