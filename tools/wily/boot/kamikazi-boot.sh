#!/bin/bash

FSTAB=/etc/fstab

# Stick a singleton in the filesystem to notate we're inside of a boot process.
touch /tmp/kamikazi-boot.stamp


echo "Kamikazi-boot: Searching for saved fstab to append..."
# Append to fstab very early if a file exists on isodevice.
if [ -d /isodevice/boot/config ]; then # the general configuration folder exists.
    if [ -f /isodevice/boot/config/fstab ]; then # we previously saved additional fstab info.
        cat /isodevice/boot/config/fstab >> ${FSTAB}
    fi
fi

echo "Kamikazi-boot: Searching for btrfs volumes to append to fstab..."
btrfs device scan  # Assemble any btrfs arrays early.

# Look for any btrfs devices.
devices=""
for device in /dev/[hsv]d[a-z][0-9]*; do
    if ! [ -b "${device}" ]; then
        continue
    fi

    /sbin/blkid -o udev -p ${device%%[0-9]*} | grep -q "^ID_FS_TYPE=btrfs" && continue

    magic=$(/bin/dd if="${device}" bs=8 skip=8200 count=1 2>/dev/null) || continue

    if [ "${magic}" = "_BHRfS_M" ]; then
        echo "Kamikazi-boot: Found a btrfs volume on ${device}"
	mkdir -p /mnt/btrfs/
        devices="${devices} ${device}"
        fi
done

# If we found any btrfs devices, check their label for uniqueness
# and then add them to the fstab referenced by their label as best as possible.

touch /tmp/kamikazi-fstab   # Make sure the file exists, silences errors.
for device in ${devices}; do
    echo "Kamikazi-boot: Looking at btrfs volume on ${device}"
    label=$(/bin/dd if="${device}" bs=1 skip=65835 count=256 2>/dev/null | tr -d '\000')
    echo "Kamikazi-boot: Discovered label on btrfs volume on ${device} is: ${label}"
    mkdir -p /mnt/btrfs/${label}
    cat >> /tmp/kamikazi-fstab <<EOF
LABEL="${label}" /mnt/btrfs/${label} btrfs defaults 0 0
EOF
    echo "Kamikazi-boot: Added a btrfs volume named /mnt/btrfs/${label} on ${device} to fstab."
done

echo "Kamikazi-boot: Sorting added btrfs volumes in fstab for uniqueness."
cat /tmp/kamikazi-fstab | sort | uniq >> ${FSTAB}
rm /tmp/kamikazi-fstab

# Mount everything we need to with early-fstab and late-fstab already in place.
echo "Kamikazi-boot: fstab complete, making sure everything is mounted..."
mount -av

# Check if ceph has configuration around, and fire it up if we find any.
if [ -f /isodevice/boot/config/ceph/ceph.conf ]; then # ceph configuration exists.
    echo "Kamikazi-boot: Found ceph config, attempting to start ceph-all..."
    /usr/sbin/service ceph-all start;  # So we should start ceph.
fi

echo "Kamikazi-boot: mount complete, attempting to update from git..."

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/

# Deal with updating our repositories.
supervisorctl start kamikazi-deploy

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-deploy | grep -q 'EXITED'; do sleep 1; done
# Wait for the while loop to break out signalling success.

echo "Kamikazi-boot: update complete, attempting to start boot-late..."

# Start the late boot process, now that the deployment is complete.
supervisorctl start kamikazi-boot-late


# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-boot-late | grep -q 'EXITED'; do sleep 1; done
# And now we should become EXITED to supervisord and any other tasks relying on the above.
