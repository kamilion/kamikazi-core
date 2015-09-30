#!/bin/bash

echo "[kamikazi-build] Adding more python stuff..."

OLDDIR=${PWD}

echo "[kamikazi-build] Compiling scrypt for python2..."
pip2 install scrypt
echo "[kamikazi-build] Compiling scrypt for python3..."
pip3 install scrypt
echo "[kamikazi-build] Compiling uwsgi for python3..."
pip3 install uwsgi
echo "[kamikazi-build] Removing uwsgi sysvinit script for python3..."
rm /etc/init.d/uwsgi
echo "[kamikazi-build] Enabling uwsgi emperor for python3..."
systemctl enable emperor.uwsgi.service

cd ${OLDDIR}

echo "[kamikazi-build] Python injection complete."
