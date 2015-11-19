#!/bin/bash

echo "[kamikazi-build] Injecting RethinkDB."

OLDDIR=${PWD}
mkdir -p /tmp/rethinkdb
cd /tmp/rethinkdb

#if [ "$(uname -m)" == "x86_64" ]; then
if [ -d /lib/x86_64-linux-gnu ]; then
  wget http://download.rethinkdb.com/apt/pool/wily/main/r/rethinkdb/rethinkdb_2.2.1~0wily_amd64.deb
elif [ -d /lib/i386-linux-gnu ]; then
  wget http://download.rethinkdb.com/apt/pool/wily/main/r/rethinkdb/rethinkdb_2.2.1~0wily_i386.deb
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
