#!/bin/bash
if [ $(blkid -s LABEL -o value /dev/sr0) == "VMware Tools"]; then
  mount /dev/sr0 /mnt
  tar -C /tmp/ -xvf /mnt/VMwareTools-*.tar.gz
  umount /dev/sr0
  /tmp/vmware-tools-distrib/vmware-install.pl -d
  /usr/bin/vmware-user
fi



