#!/bin/bash

# V0.5.0 uses this from serf triggered upgrades.

# Get into our main directory for it to be the CWD for the rest.
cd /tmp/

# Remove any existing downloaded ISO.
rm kamikazi.iso

# Obtain a new ISO from the following URL.
wget ${1}

cp /tmp/kamikazi.iso /isodevice/boot/isos/kamikazi.iso
sync
