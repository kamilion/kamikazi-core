#!/bin/bash
if [ "$(/sbin/blkid -s LABEL -o value /dev/sr0)" == "VMware Tools" ]; then
  mount /dev/sr0 /mnt
  tar -C /tmp/ -xf /mnt/VMwareTools-*.tar.gz
  umount /dev/sr0
  /tmp/vmware-tools-distrib/vmware-install.pl -d
  rm -Rf /tmp/vmware-tools-distrib/
  /usr/bin/vmware-user
fi



