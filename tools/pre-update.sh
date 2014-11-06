#!/bin/bash

# V0.5.0 Runs this script first during a deploy to deal with disabling services.

# Does the boot stamp exist? If so, we're booting and boot-late may swapon -a.
if [ -f /tmp/kamikazi-boot.stamp ]; then
    # We have no idea how many disks are connected. Hopefully it's less than 96.
    echo "pre-update: v0.5.0 Image Boot: Turning off all swap."

    for i in {0..96}; do
        swapoff -a
    done
else
    # We're not in a bootup, so we'd better stop stuff we might change during deploy.
    echo "pre-update: Stopping diskmonitor."
    supervisorctl stop kamikazi-diskmonitor

    echo "pre-update: Stopping diskworker."
    supervisorctl stop kamikazi-diskworker
fi

echo "pre-update: Nothing left to do."


