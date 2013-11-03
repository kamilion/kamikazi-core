#!/bin/bash

# Are we running in livemedia mode?
if [ -d /isodevice ]; then
    echo "do-install: Running in live mode."
    # post-update.sh should have already run, providing us with version files.

    # Check if we're running a fresh gang-flashed USB stick with 0.4.0.
    if [ -f /isodevice/kamikazi-0.4.0.ver ]; then
        echo "do-install: Found a marker from Disk Image version 0.4.0."
        echo "do-install: Triggering a backround update to 0.5.0."
        echo "do-install: To abort, quickly ssh in and killall do-zurfa-upgrade.sh"
        $(zurfa-deploy/tools/do-zurfa-upgrade.sh) &
    fi

    # Check if we're running an updated USB stick with 0.5.0.
    if [ -f /isodevice/kamikazi-0.5.0.ver ]; then
        echo "do-install: Found a marker from Disk Image version 0.5.0."

        # Check if we're running a prototyping USB stick with 0.5.0-pre and both version markers.
        if [ -f /isodevice/kamikazi-0.4.0.ver ]; then
            echo "do-install: Purging a marker from Disk Image version 0.4.0."
            rm /isodevice/kamikazi-0.4.0.ver
            echo "do-install: Triggering a backround update to latest 0.5.0."
            echo "do-install: To abort, quickly ssh in and killall do-zurfa-upgrade.sh"
            $(zurfa-deploy/tools/do-zurfa-upgrade.sh) &
        fi
    fi
fi

echo "do-install: Nothing left to do."

