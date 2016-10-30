#!/bin/bash

FSTAB=/etc/fstab

echo "kamikazi-diskarray-mount: Searching for saved fstab to append..."
# Append to fstab very early if a file exists on isodevice.
if [ -d /isodevice/boot/config ]; then # the general configuration folder exists.
    if [ -f /isodevice/boot/config/fstab ]; then # we previously saved additional fstab info.
        cat /isodevice/boot/config/fstab >> ${FSTAB}
    fi
fi

echo "kamikazi-diskarray-mount: Searching for btrfs volumes to append to fstab..."
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
        echo "kamikazi-diskarray-mount: Found a btrfs volume on ${device}"
	mkdir -p /mnt/btrfs/
        devices="${devices} ${device}"
        fi
done

# If we found any btrfs devices, check their label for uniqueness
# and then add them to the fstab referenced by their label as best as possible.

cp ${FSTAB} /tmp/kamikazi-fstab   # Make sure the file exists, silences errors.
for device in ${devices}; do
    echo "kamikazi-diskarray-mount: Looking at btrfs volume on ${device}"
    label=$(/bin/dd if="${device}" bs=1 skip=65835 count=256 2>/dev/null | tr -d '\000')
    if [ "${label}" = "" ]; then # skip adding it to fstab.
        echo "kamikazi-diskarray-mount: No label on btrfs volume on ${device}, skipping.";
        continue;  # continue does goto do above, break does goto done below.
    fi
    echo "kamikazi-diskarray-mount: Discovered label on btrfs volume on ${device} is: ${label}"
    mkdir -p /mnt/btrfs/${label}
    cat >> /tmp/kamikazi-fstab <<EOF
LABEL="${label}" /mnt/btrfs/${label} btrfs defaults 0 0
EOF
    echo "kamikazi-diskarray-mount: Added a btrfs volume named /mnt/btrfs/${label} on ${device} to fstab."
done

echo "kamikazi-diskarray-mount: Sorting added btrfs volumes in fstab for uniqueness."
cat /tmp/kamikazi-fstab | sort | uniq >> ${FSTAB}
rm /tmp/kamikazi-fstab

echo "kamikazi-diskarray-diskmount: Sorting fstab for uniqueness."
sort -o /etc/fstab -u /etc/fstab

# Mount everything we need to with early-fstab and late-fstab already in place.
echo "kamikazi-diskarray-mount: fstab complete, making sure everything is mounted..."
mount -av

# Keep supervisord from complaining this job is too short.
sleep 3
echo "kamikazi-diskarray-mount: Nothing left to do."
