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

# Ask systemctl to create the link (Not sure if this needs dbus)
systemctl enable serf
# Fall back and ensure the link is created ourselves.
cd /etc/systemd/system/multi-user.target.wants/
ln -vfs /etc/systemd/system/serf.service serf.service

cd ${OLDDIR}

echo "[kamikazi-build] serf binary injection complete."
