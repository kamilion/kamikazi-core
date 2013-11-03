#!/bin/bash

# Get into our main directory for it to be the CWD for the rest.
cd /tmp/

# Remove any existing downloaded ISO.
rm kamikazi.iso

# Obtain a new ISO from the following URL.
wget ${2}

cp /tmp/kamikazi.iso /isodevice/boot/isos/kamikazi.iso
sync
