#!/bin/bash

echo "[kamikazi-build] Injecting serf binary."

OLDDIR=${PWD}
mkdir -p /tmp/serfdom
cd /tmp/serfdom

#if [ "$(uname -m)" == "x86_64" ]; then
if [ -d /lib/x86_64-linux-gnu ]; then
  wget http://files.sllabs.com/files/long-term/downloads/serf/0.6.4_linux_amd64.zip
  # https://dl.bintray.com/mitchellh/serf/0.6.4_linux_amd64.zip
elif [ -d /lib/i386-linux-gnu ]; then
  wget http://files.sllabs.com/files/long-term/downloads/serf/0.6.4_linux_386.zip
  # https://dl.bintray.com/mitchellh/serf/0.6.4_linux_386.zip
fi

unzip 0.6.4_linux_*.zip
mv serf /usr/local/bin/serf
rm 0.6.4_linux_*.zip
cd /tmp
rmdir serfdom

cd ${OLDDIR}

echo "[kamikazi-build] serf binary injection complete."
