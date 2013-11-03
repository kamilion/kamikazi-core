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
  sync
fi

# Update grub.
cp zurfa-deploy/resources/grub/grub.cfg /isodevice/boot/grub/grub.cfg
sync

echo "do-zurfa-upgrade: Sleeping 60 seconds for operator to remote abort."
sleep 60

# Do the ISO upgrade procedure.
zurfa-deploy/tools/zurfa-upgrade.sh ${ZU_URL}

# Assure the data has met the media
sync; sync; sync;

# Subshell a shutdown two minutes from now and exit cleanly.
$(shutdown -r 2) &

exit 0;