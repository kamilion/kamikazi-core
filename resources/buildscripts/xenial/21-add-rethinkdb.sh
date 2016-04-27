#!/bin/bash

echo "[kamikazi-build] Injecting RethinkDB."

OLDDIR=${PWD}
mkdir -p /tmp/rethinkdb
cd /tmp/rethinkdb

#if [ "$(uname -m)" == "x86_64" ]; then
if [ -d /lib/x86_64-linux-gnu ]; then
  wget http://files.sllabs.com/files/long-term/downloads/packages/rethinkdb_2.3.1-0xenial_amd64.deb
elif [ -d /lib/i386-linux-gnu ]; then
  wget http://files.sllabs.com/files/long-term/downloads/packages/rethinkdb_2.3.1-0xenial_i386.deb
fi

dpkg -i rethinkdb_2.*.deb

pip install rethinkdb
pip3 install rethinkdb

cd /tmp
rmdir rethinkdb

# Ask systemctl to create the link (Not sure if this needs dbus)
systemctl enable rethinkdb

cd ${OLDDIR}

echo "[kamikazi-build] RethinkDB injection complete."
