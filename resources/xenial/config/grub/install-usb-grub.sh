#!/usr/bin/bash
mymount="/media/ubuntu/boot"
mydevice="/dev/sda"

sudo grub-install --force --no-floppy --root-directory=$mymount $mydevice
#cp grub.cfg $mymount/boot/grub/
#cp ../../*.{iso,img,bin} $mymount
