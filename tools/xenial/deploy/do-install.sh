#!/bin/bash

# V0.8.0 Runs this script fifth during a deploy to deal with automatic platform updating.

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
KCHOME="/home/git/kamikazi-core"
KCRES="${KCHOME}/resources/latest"

# Are we running in livemedia mode?
if [ -d /isodevice ]; then
    echo "do-install: Running in live mode."
    # post-update.sh should have already run, providing us with version files.

    # Check if we're running a fresh gang-flashed USB stick with 0.4.0.
    if [ -f /isodevice/kamikazi-0.4.0.ver ]; then
        echo "do-install: Found a marker from Disk Image version 0.4.0."
        rm /isodevice/kamikazi-0.4.0.ver;
        echo "do-install: Purged a marker from Disk Image version 0.4.0."
        echo "do-install: Triggering a background update to latest image."
        echo "do-install: To abort, quickly ssh in and killall do-kamikazi-upgrade.sh"
        # Import a supervisor job to do it.
        cp ${KCRES}/mods/etc/supervisor/conf.d/kamikazi-upgrade.conf /etc/supervisor/conf.d/
        sync
        supervisorctl reread
        supervisorctl update

        # If we have a supervisor job to do it, prefer that.
        if [ -f /etc/supervisor/conf.d/kamikazi-upgrade.conf ]; then
            supervisorctl start kamikazi-upgrade
        else  # Call the script directly.
            $(${KCHOME}/tools/latest/upgrade/do-kamikazi-upgrade.sh) &
        fi
    fi

    # Check if we're running an updated USB stick with 0.5.0.
    if [ -f /isodevice/kamikazi-0.5.0.ver ]; then
        echo "do-install: Found a marker from Disk Image version 0.5.0."
        rm /isodevice/kamikazi-0.5.0.ver;
        echo "do-install: Purged a marker from Disk Image version 0.5.0."
        echo "do-install: Triggering a background update to latest image."
        echo "do-install: To abort, quickly ssh in and killall do-kamikazi-upgrade.sh"
        # Import a supervisor job to do it.
        cp ${KCRES}/mods/etc/supervisor/conf.d/kamikazi-upgrade.conf /etc/supervisor/conf.d/
        sync
        supervisorctl reread
        supervisorctl update

        # If we have a supervisor job to do it, prefer that.
        if [ -f /etc/supervisor/conf.d/kamikazi-upgrade.conf ]; then
            supervisorctl start kamikazi-upgrade
        else  # Call the script directly.
            $(${KCHOME}/tools/latest/upgrade/do-kamikazi-upgrade.sh) &
        fi
    fi

    # Check if we're running a prototyping USB stick with the 0.0.0 force-reflash marker.
    if [ -f /isodevice/kamikazi-0.0.0.ver ]; then
        echo "do-install: Purging a force-reflash marker from Disk Image version 0.0.0."
        rm /isodevice/kamikazi-0.0.0.ver
        echo "do-install: Triggering a background update to latest image."
        echo "do-install: To abort, quickly ssh in and killall do-kamikazi-upgrade.sh"
        # Import a supervisor job to do it.
        cp ${KCRES}/mods/etc/supervisor/conf.d/kamikazi-upgrade.conf /etc/supervisor/conf.d/
        sync
        supervisorctl reread
        supervisorctl update

        # If we have a supervisor job to do it, prefer that.
        if [ -f /etc/supervisor/conf.d/kamikazi-upgrade.conf ]; then
            supervisorctl start kamikazi-upgrade
        else  # Call the script directly.
            $(${KCHOME}/tools/latest/upgrade/do-kamikazi-upgrade.sh) &
        fi
    fi
fi

echo "do-install: Nothing left to do."

