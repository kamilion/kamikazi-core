#!/bin/bash

echo "[kamikazi-build] Adding more python stuff..."

OLDDIR=${PWD}

pip2 install scrypt
pip3 install uwsgi scrypt

cd ${OLDDIR}

echo "[kamikazi-build] Python injection complete."
