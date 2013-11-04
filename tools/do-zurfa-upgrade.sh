#!/bin/bash

# V0.5.0 Runs this script during a deploy to deal with platform updates.

# NOTE: THE ISO FILENAME MUST STAY THE SAME!
ZU_URL="http://10.0.5.253/files/tmp/kamikazi.iso"

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
ZDHOME="/home/git/zurfa-deploy"
ZDRES="${ZDHOME}/resources"

echo "do-zurfa-upgrade: Going to update from:"
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

# Update grub so restarting is safe.
cp ${ZDRES}/grub/grub.cfg /isodevice/boot/grub/grub.cfg
sync

echo "do-zurfa-upgrade: Sleeping 60 seconds for operator to remote abort."
sleep 60

# Do the ISO upgrade procedure.
${ZDHOME}/tools/zurfa-upgrade.sh ${ZU_URL}

# Assure the data has met the media
sync; sync; sync;

# Subshell a shutdown two minutes from now and exit cleanly.
$(shutdown -r 2) &

exit 0;