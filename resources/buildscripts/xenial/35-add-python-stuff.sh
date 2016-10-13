#!/bin/bash

echo "[kamikazi-build] Adding more python stuff..."

OLDDIR=${PWD}

echo "[kamikazi-build] Upgrading pip for python3..."
pip3 install --upgrade pip
echo "[kamikazi-build] Upgrading pip for python2..."
pip2 install --upgrade pip

echo "[kamikazi-build] Compiling xonsh for python3..."
pip3 install xonsh
echo "[kamikazi-build] Compiling dask and distributed for python3..."
pip3 install distributed
echo "[kamikazi-build] Compiling dask and distributed for python2..."
pip2 install distributed
echo "[kamikazi-build] Compiling luigi for python3..."
pip3 install 'python-daemon<3.0' luigi
echo "[kamikazi-build] Compiling ajenti-requirements for python2..."
pip2 install gevent-socketio python-daemon-3k gipc 
pip2 install 'pyte==0.4.9'
pip2 install 'jadi>=1.0.3'
echo "[kamikazi-build] Compiling scrypt for python2..."
pip2 install scrypt
echo "[kamikazi-build] Compiling scrypt for python3..."
pip3 install scrypt
echo "[kamikazi-build] Compiling uwsgi for python3..."
pip3 install uwsgi
echo "[kamikazi-build] Removing uwsgi sysvinit script for python3..."
rm -f /etc/init.d/uwsgi
echo "[kamikazi-build] Enabling uwsgi emperor for python3..."
systemctl enable emperor.uwsgi.service

cd ${OLDDIR}

echo "[kamikazi-build] Python injection complete."
