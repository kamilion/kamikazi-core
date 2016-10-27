#!/bin/bash

echo "[kamikazi-build] Injecting Customizer from git."

OLDDIR=${PWD}
mkdir -p /tmp/customizer-build
cd /tmp/customizer-build

git clone https://github.com/kamilion/customizer.git
cd customizer
make && make install
cd ..
rm -Rf customizer

cd /tmp
rmdir customizer-build

cd ${OLDDIR}

echo "[kamikazi-build] Customizer injection complete."
