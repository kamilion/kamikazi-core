#!/bin/bash

# V0.5.0 Runs this script third during a deploy to deal with Volatile USB Storage.

ZDHOME="/home/git/zurfa-deploy"
ZDRES="${ZDHOME}/resources"

# Are we running in livemedia mode?
if [ -d /isodevice ]; then
    echo "post-update: Running in live mode."

    ### First, we need to ensure any optional icons are populated if they're needed.
    ## We assume the user of the livecd is named 'ubuntu', as is the normal livecd default.

    ## Check to see if the root-terminal icon exists. If not, make it.
    if [ ! -f /home/ubuntu/Desktop/root-terminal.desktop ]; then
        cp ${ZDRES}/mods/etc/skel/Desktop/root-terminal.desktop /home/ubuntu/Desktop/
        chown 999:999 /home/ubuntu/Desktop/root-terminal.desktop
        echo "post-update: Added root-terminal icon."
    fi

    ## Check to see if the disker-terminal icon exists. If not, make it.
    if [ ! -f /home/ubuntu/Desktop/disker-terminal.desktop ]; then
        cp ${ZDRES}/mods/etc/skel/Desktop/disker-terminal.desktop /home/ubuntu/Desktop/
        chown 999:999 /home/ubuntu/Desktop/disker-terminal.desktop
        echo "post-update: Added disker-terminal icon."
    fi

    ## We're probably too late to influence some things like pcmanfm, but at least we can fix chromium.
    if [ ! -d /home/ubuntu/.config/chromium ]; then  ## Chromium's profile doesn't exist yet.
        cp -a ${ZDRES}/mods/etc/skel/.config /etc/skel/
        cp -a ${ZDRES}/mods/etc/skel/.config /home/ubuntu/
        chown -R 999:999 /home/ubuntu/.config/
        echo "post-update: Added additional skel."
    fi

    ### Second, we need to do a little version management of our USB stick.

    ## Version 4 image check: Does not have /etc/kamikazi-0.5.0.ver
    if [ ! -f /etc/kamikazi-0.5.0.ver ]; then
        touch /isodevice/kamikazi-0.4.0.ver
        echo "post-update: Touched kamikazi 0.4.0 version file."
    fi

    ## Version 5 image check: Imprints USB device.
    if [ ! -f /isodevice/kamikazi-0.5.0.ver ]; then
        touch /isodevice/kamikazi-0.5.0.ver
        echo "post-update: Touched kamikazi 0.5.0 version file."
    fi

    ## Version 5 config check: Imprints USB device.
    if [ ! -d /isodevice/boot/config ]; then  # We should make the directory
        echo "post-update: No config folder found on USB. Creating."
        mkdir -p /isodevice/boot/config
    fi

    ## Version 5 machine-id check: Imprints USB device.
    if [ ! -f /isodevice/boot/config/machine-id ]; then  # We should populate it.
        cp /var/lib/dbus/machine-id /isodevice/boot/config/machine-id
        echo "post-update: Created kamikazi 0.5.0 machine-id file."
    fi

    ## Version 5 hostname check: Imprints USB device.
    if [ ! -f /isodevice/boot/config/hostname ]; then  # We should populate it.
        MYHOST=$(hostname);  # Get the current hostname
        if [ "${MYHOST}" != "ubuntu" ]; then  # Protect against old livecd defaults
            echo ${MYHOST} > /isodevice/boot/config/hostname
            echo "post-update: Created kamikazi 0.5.0 hostname file."
        fi
    fi

    ## Version 5 ssh-host-key check: Imprints USB device.
    if [ ! -d /isodevice/boot/config/ssh ]; then
        echo "post-update: No ssh config folder found on USB. Creating."
        mkdir -p /isodevice/boot/config/ssh
        cp /etc/ssh/ssh_host_* /isodevice/boot/config/ssh
    else
        echo "post-update: ssh config folder found on USB. Checking."
        cd /etc/ssh/
        sha1sum ssh_host_* > /tmp/running_ssh
        cd /isodevice/boot/config/ssh/
        sha1sum ssh_host_* > /tmp/usb_ssh
        if ! $(cmp /tmp/running_ssh /tmp/usb_ssh); then
            echo "post-update: Local ssh host keys did not match USB. Updating USB host keys."
            rm /isodevice/boot/config/ssh/ssh_host_*
            cp /etc/ssh/ssh_host_* /isodevice/boot/config/ssh
        else
            echo "post-update: Local ssh host keys matched USB."
        fi
        rm /tmp/running_ssh /tmp/usb_ssh
        cd /home/git
    fi

    ## Print which image version was found.
    if [ -f /isodevice/kamikazi-0.4.0.ver ]; then
        echo "post-update: Found a marker from Disk Image version 0.4.0."
    fi
    if [ -f /isodevice/kamikazi-0.5.0.ver ]; then
        echo "post-update: Found a marker from Disk Image version 0.5.0."
    fi
fi

echo "post-update: Nothing left to do."


