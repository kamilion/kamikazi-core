#!/bin/bash

echo "Cleaning ISO from lubuntu-14.10-amd64.iso"

# Remove that file we used to prevent whoopsie from puking.
rm -f /etc/init.d/whoopsie
# Remove this socket that causes unpacking squashfs to warn.
rm -f /run/synaptic.socket
# Remove chronyd's pidfile.
rm -f /run/chronyd.pid
