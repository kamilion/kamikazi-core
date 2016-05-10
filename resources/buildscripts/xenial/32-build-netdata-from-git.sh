#!/bin/bash

echo "[kamikazi-build] Injecting firehol/netdata binaries."

echo "[kamikazi-build] Installing packages for netdata."
apt-get install -y zlib1g-dev gcc make git autoconf autogen automake pkg-config nodejs-legacy
sleep 2

OLDDIR=${PWD}
mkdir -p /tmp/firehol
cd /tmp/firehol

# Get from git.
git clone https://github.com/firehol/netdata --depth=1
cd netdata
sleep 2
./netdata-installer.sh --dont-wait --dont-start-it
cp system/netdata.service /etc/systemd/system/netdata.service
sleep 2
# Cleanup
cd /tmp
# Remove the checked out git repo.
#rm -Rf /tmp/firehol/*
# Remove the now-empty directory the git repo was in.
#rmdir firehol
sleep 2

# Ask systemctl to create the link (Not sure if this needs dbus)
systemctl enable netdata
# Fall back and ensure the link is created ourselves.
cd /etc/systemd/system/multi-user.target.wants/
ln -vfs /etc/systemd/system/netdata.service netdata.service


cd ${OLDDIR}

echo "[kamikazi-build] firehol/netdata binary injection complete."
