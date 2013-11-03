#!/bin/bash

# NOTE: THE ISO FILENAME MUST STAY THE SAME!
ZU_URL="http://10.0.5.253/files/tmp/kamikazi.iso"

echo "do-zurfa-upgrade: This is not 0.5.0, going to update from:"
echo ${ZU_URL}

# Remove the old grub.cfg~ file.
if [ -f /isodevice/boot/grub/grub.cfg~ ]; then
  rm /isodevice/boot/grub/grub.cfg~
fi

# Free up some space on the USB device.
if [ -f /isodevice/boot/isos/pmagic_2013_02_28.iso ]; then
  rm /isodevice/boot/isos/pmagic_2013_02_28.iso
fi

zurfa-deploy/tools/zurfa-upgrade.sh ${ZU_URL}
cp zurfa-deploy/resources/grub/grub.cfg /isodevice/boot/grub/grub.cfg

# Assure the data has met the media
sync; sync; sync;

# Subshell a shutdown one minute from now and exit cleanly.
#$(shutdown -r 1 &) && exit 0;
$(sleep 60 &) && exit 0;