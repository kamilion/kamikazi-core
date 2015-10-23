#!/bin/bash

# Stick a singleton in the filesystem to notate we're inside of a boot process.
touch /tmp/kamikazi-boot.stamp

echo "Kamikazi-boot: Attempting to start network..."

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/


# NETWORK: Requirements: None, config restored by kamikazi-restore.
# Deal with starting up the network.
supervisorctl start kamikazi-vswitch

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-vswitch | grep -q 'EXITED'; do sleep 1; done
# Wait for the while loop to break out signalling success.

echo "Kamikazi-boot: Network start complete, attempting to update from git..."


# GIT: Requirements: Internet access over network
# Deal with updating our repositories.
supervisorctl start kamikazi-deploy

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-deploy | grep -q 'EXITED'; do sleep 1; done
# Wait for the while loop to break out signalling success.

echo "Kamikazi-boot: Git update complete, attempting to mount disks..."


# DISKMOUNT: Requirements: BTRFS partitions on disk, with labels set.
# Deal with mounting our disks.
supervisorctl start kamikazi-diskmount

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-diskmount | grep -q 'EXITED'; do sleep 1; done
# Wait for the while loop to break out signalling success.


# CEPH: Requirements: network & mounted disks
# Check if ceph has configuration around, and fire it up if we find any.
if [ -f /isodevice/boot/config/ceph/ceph.conf ]; then # ceph configuration exists.
    echo "Kamikazi-boot: Found ceph config, attempting to start ceph-all..."
    /usr/sbin/service ceph-all start;  # So we should start ceph.
fi

echo "Kamikazi-boot: Disks mounted, attempting to start boot-late..."


# LATE: Requirements: All networks should be up & all disks mounted.
# Start the late boot process, now that the deployment is complete.
supervisorctl start kamikazi-boot-late

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-boot-late | grep -q 'EXITED'; do sleep 1; done
# And now we should become EXITED to supervisord and any other tasks relying on the above.
