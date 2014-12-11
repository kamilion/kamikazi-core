#!/bin/bash

# V0.5.0 uses this instead of post-boot.sh
FSTAB=/etc/fstab

# Stick a singleton in the filesystem to notate we're inside of a boot process.
touch /tmp/kamikazi-boot.stamp

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

labels=""    # Create a string variable to hold the labels, then abuse string replacement.
for device in ${devices}; do
    label=$(/bin/dd if="${device}" bs=1 skip=65835 count=256 2>/dev/null | tr -d '\000')
    if [ -z ${labels##*$label*} ] && [ -z "${labels}" -o -n "${label}" ]; then
        labels="${labels} ${label}"
        echo "Kamikazi-boot: Added a btrfs volume named /mnt/btrfs/${label} on ${device} to fstab."
        mkdir -p /mnt/btrfs/${label}
        cat >> ${FSTAB} <<EOF
LABEL="${label}" /mnt/btrfs/${label} btrfs defaults 0 0
EOF
    fi
done


echo "Kamikazi-boot: Searching for saved fstab to append..."
# Append to fstab very early if a file exists on isodevice.
if [ -d /isodevice/boot/config ]; then # the general configuration folder exists.
    if [ -f /isodevice/boot/config/fstab ]; then # we previously saved additional fstab info.
        cat /isodevice/boot/config/fstab >> ${FSTAB}
    fi
fi


# Get into our main directory for it to be the CWD for the rest.
cd /home/git/

# Deal with updating our repositories.
supervisorctl start kamikazi-deploy

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-deploy | grep -q 'EXITED'; do sleep 1; done
# Wait for the while loop to break out signalling success.

# Start the late boot process, now that the deployment is complete.
supervisorctl start kamikazi-boot-late


# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-boot-late | grep -q 'EXITED'; do sleep 1; done
# And now we should become EXITED to supervisord and any other tasks relying on the above.
