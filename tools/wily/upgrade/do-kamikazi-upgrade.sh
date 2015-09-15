#!/bin/bash

# V0.8.0 Runs this script during a deploy to deal with platform updates.

# NOTE: THE ISO FILENAME MUST STAY THE SAME!
KU_URL="http://10.0.5.253/files/tmp/kamikazi.iso"

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
KCHOME="/home/git/kamikazi-core"
KCRES="${KCHOME}/resources/latest"

echo "do-kamikazi-upgrade: Going to update from:"
echo ${KU_URL}

# Remove the old grub.cfg~ file.
if [ -f /isodevice/boot/grub/grub.cfg~ ]; then
  rm /isodevice/boot/grub/grub.cfg~
fi

# Update grub so restarting is safe.
cp ${KCRES}/config/grub/grub.cfg /isodevice/boot/grub/grub.cfg
sync

echo "do-kamikazi-upgrade: Sleeping 60 seconds for operator to remote abort."
sleep 60

# Do the ISO upgrade procedure.
$(${KCHOME}/tools/latest/upgrade/kamikazi-upgrade.sh ${KU_URL})

# Assure the data has met the media
sync; sync; sync;

# Subshell a shutdown two minutes from now and exit cleanly.
$(shutdown -r 2) &

exit 0;
