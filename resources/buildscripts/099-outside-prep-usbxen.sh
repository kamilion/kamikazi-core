#!/bin/bash

# Put Xen in place on the ISO.
cp /home/ubuntu-builder/FileSystem/boot/xen-4.4-amd64.gz /home/ubuntu-builder/ISO/casper/xen-4.4-amd64.gz 
# Put our USB config on the ISO.
cp usbgrub.cfg /home/ubuntu-builder/ISO/casper/usbgrub.cfg
