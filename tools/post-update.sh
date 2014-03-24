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

    ## Check to see if the Kaizen icon exists. If not, make it.
    if [ ! -f /home/ubuntu/Desktop/kaizen.desktop ]; then
        cp ${ZDRES}/mods/etc/skel/Desktop/kaizen.desktop /home/ubuntu/Desktop/
        chown 999:999 /home/ubuntu/Desktop/kaizen.desktop
        echo "post-update: Added Kaizen icon."
    fi

    if [ ! -d /home/ubuntu/.x2goclient ]; then  ## x2go has no profile yet.
        cp -a ${ZDRES}/mods/etc/skel/.x2goclient /etc/skel/
        cp -a ${ZDRES}/mods/etc/skel/.PyCharm30 /etc/skel/
        cp -a ${ZDRES}/mods/etc/skel/.x2goclient /home/ubuntu/
        cp -a ${ZDRES}/mods/etc/skel/.PyCharm30 /home/ubuntu/
        chown -R 999:999 /home/ubuntu/.x2goclient/
        chown -R 999:999 /home/ubuntu/.PyCharm30/
        echo "post-update: Added additional x2go sessions and pycharm skel."
    fi

    ## We're probably too late to influence some things like pcmanfm, but at least we can fix chromium.
    if [ ! -d /home/ubuntu/.config/chromium ]; then  ## Chromium's profile doesn't exist yet.
        cp -a ${ZDRES}/mods/etc/skel/.config /etc/skel/
        cp -a ${ZDRES}/mods/etc/skel/.gconf /etc/skel/
        cp -a ${ZDRES}/mods/etc/skel/.config /home/ubuntu/
        cp -a ${ZDRES}/mods/etc/skel/.gconf /home/ubuntu/
        chown -R 999:999 /home/ubuntu/.config/
        chown -R 999:999 /home/ubuntu/.gconf/
        echo "post-update: Added additional chromium skel."
    fi

    ## Fix up the log files so all the disk spam ends up somewhere easy to deal with
    if [ ! -f /etc/rsyslog.d/35-disks.conf ]; then  ## Not baked in yet
        cp -a ${ZDRES}/mods/etc/rsyslog.d/35-disks.conf /etc/rsyslog.d/
        service rsyslog restart
        echo "post-update: Added additional rsyslog.d log target."
    fi

    ## Fix up enum34 for python so smarttools and diskmonitor works
    if [ ! -f /usr/local/lib/python2.7/dist-packages/enum34-*.egg-info/PKG-INFO ]; then  ## Not baked in yet
        pip install enum34
        echo "post-update: Installed enum34 via pip."
    fi

    ### Second, we need to do a little version management of our USB stick.

    ## Image Version check: Does it have a /etc/kamikazi-?.?.?.ver file?
    if [ ! -f /etc/kamikazi-?.?.?.ver ]; then  # We do not have a versioned image.
        echo "post-update: Could not find a version file in /etc."
        touch /isodevice/kamikazi-0.4.0.ver
        echo "post-update: Touched kamikazi 0.4.0 version file on USB."
    else  # Copy the version tag from the iso to the USB device.
        cp /etc/kamikazi-?.?.?.ver /isodevice/
    fi

    ## Version 5+ config check: Imprints USB device.
    if [ ! -d /isodevice/boot/config ]; then  # We should make the directory
        echo "post-update: No config folder found on USB. Creating."
        mkdir -p /isodevice/boot/config
    fi

    ## Version 5+ machine-id check: Imprints USB device.
    if [ ! -f /isodevice/boot/config/machine-id ]; then  # We should populate it.
        cp /var/lib/dbus/machine-id /isodevice/boot/config/machine-id
        echo "post-update: Created kamikazi 0.5.0+ machine-id file."
    fi

    ## Version 6+ hostname check: Imprints USB device.
    if [ ! -f /isodevice/boot/config/hostname ]; then  # We should populate it.
        MYHOST=$(hostname);  # Get the current hostname
        if [ "${MYHOST}" != "ubuntu" ]; then  # Protect against old livecd defaults
            echo ${MYHOST} > /isodevice/boot/config/hostname
            echo "post-update: Created kamikazi 0.6.0+ hostname file."
        fi
    fi

    ## Version 5+ ssh-host-key check: Imprints USB device.
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

    ## Version 6 image check: Does have /etc/kamikazi-0.6.0.ver
    if [ -f /isodevice/kamikazi-0.6.0.ver ]; then
        echo "post-update: Found kamikazi 0.6.0 version file on USB."
        # Update grub so restarting is safe.
        cd ${ZDRES}/grub/
        sha1sum grub.cfg > /tmp/running_grub
        cd /isodevice/boot/grub/
        sha1sum grub.cfg > /tmp/usb_grub
        if ! $(cmp /tmp/running_grub /tmp/usb_grub); then
            echo "post-update: Updating GRUB Configuration file on USB."
            cp ${ZDRES}/grub/grub.cfg /isodevice/boot/grub/grub.cfg
            sync
            echo "post-update: Updated GRUB Configuration file for v0.6.x on USB."
        fi
        rm /tmp/running_grub /tmp/usb_grub
        cd /home/git
    fi

    ## Version 5 image check: Does have /etc/kamikazi-0.5.0.ver
    if [ -f /isodevice/kamikazi-0.5.0.ver ]; then
        echo "post-update: Found kamikazi 0.5.0 version file on USB."
    fi

    ## Version 4 image check: Does not have /etc/kamikazi-0.x.0.ver
    if [ -f /isodevice/kamikazi-0.4.0.ver ]; then
        echo "post-update: Found kamikazi 0.4.0 version file on USB."
    fi

    echo "post-update: Nothing left to do in live-mode."
fi

echo "post-update: Nothing left to do."


