#!/bin/bash

echo "[kamikazi-build] Injecting Customizer from git."

OLDDIR=${PWD}
mkdir -p /tmp/customizer
cd /tmp/customizer

git clone https://github.com/clearkimura/Customizer.git
cd Customizer
make && make install
cd ..
rm -Rf Customizer

cd /tmp
rmdir customizer

cd ${OLDDIR}

echo "[kamikazi-build] Customizer injection complete."
