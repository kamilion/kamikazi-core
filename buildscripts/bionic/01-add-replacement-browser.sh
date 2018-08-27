#!/bin/bash

echo "[kamikazi-build] Injecting Falkon."

OLDDIR=${PWD}
mkdir -p /tmp/falkon
cd /tmp/falkon

#if [ "$(uname -m)" == "x86_64" ]; then
if [ -d /lib/x86_64-linux-gnu ]; then
  wget https://files.sllabs.com/files/long-term/downloads/packages/falkon_3.0.99_no_kwallet_ubuntu18.04.1_amd64.deb
elif [ -d /lib/i386-linux-gnu ]; then
  wget https://files.sllabs.com/files/long-term/downloads/packages/falkon_3.0.99_no_kwallet_ubuntu18.04.1_i386.deb
fi

gdebi -n falkon_3.*.deb

cd /tmp
rm -Rf /tmp/falkon/*
rmdir falkon

cd ${OLDDIR}

echo "[kamikazi-build] Falkon injection complete."
