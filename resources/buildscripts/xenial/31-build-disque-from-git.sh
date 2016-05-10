#!/bin/bash

echo "[kamikazi-build] Injecting disque binaries."

echo "[kamikazi-build] Installing tcl 8.6 packages for disque: make test."
apt-get install -y tcl8.6
sleep 2

OLDDIR=${PWD}
mkdir -p /tmp/disque
cd /tmp/disque

# Get from git.
git clone https://github.com/antirez/disque
cd disque
sleep 2
# Run make.
make
sleep 2
# run make test.
make test
sleep 2
# run make install.
make install
sleep 2
# Cleanup
cd /tmp
# Remove the checked out git repo.
rm -Rf /tmp/disque/*
# Remove the now-empty directory the git repo was in.
rmdir disque
sleep 2

# Install the python client from pip
pip2 install pydisque
pip3 install pydisque

# Ask systemctl to create the link (Not sure if this needs dbus)
systemctl enable disque
# Fall back and ensure the link is created ourselves.
cd /etc/systemd/system/multi-user.target.wants/
ln -vfs /etc/systemd/system/disque.service disque.service

echo "[kamikazi-build] Removing tcl packages."
apt-get purge -y libtcl8.6 tcl8.6
sleep 2

cd ${OLDDIR}

echo "[kamikazi-build] disque binary injection complete."
