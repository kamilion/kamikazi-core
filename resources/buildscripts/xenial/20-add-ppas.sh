#!/bin/bash

echo "[kamikazi-build] Injecting PPAs and packages."
apt-get autoremove --purge -y

echo "[kamikazi-build] Injecting x2go repository"
# Development Repo
#wajig addrepo ppa:kamilion/x2go-kamikazi
# Stable Repo
add-apt-repository -y -u ppa:x2go/stable
packages="x2goserver x2golxdebindings x2godesktopsharing pyhoca-gui x2goclient"
apt-get install -y ${packages}

echo "[kamikazi-build] Injecting whdd repository"
add-apt-repository -y -u ppa:kamilion/whdd
packages="whdd"
apt-get install -y ${packages}

echo "[kamikazi-build] PPA injection complete."
