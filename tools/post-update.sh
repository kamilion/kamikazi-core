#!/bin/bash -x

# Are we running in livemedia mode?
if [ -d /isodevice ]; then

    ### First, we have the problem of swap being automatically mounted by the livemedia.

    ## We have no idea how many disks are connected. Hopefully it's less than 96.
    echo "post-update: Turning off all swap."

    for i in {0..96}
      do
        swapoff -a
      done

    ### Second, we need to do a little version management of our USB stick.

    ## Version 4 image check: Does not have /etc/kamikazi-0.5.0.ver
    if [ ! -f /etc/kamikazi-0.5.0.ver ]; then
        touch /isodevice/kamikazi-0.4.0.ver
        echo "post-update: Touched kamikazi 0.4.0 version file."
    fi

    ## Version 5 image check: Imprint USB device.
    if [ ! -f /isodevice/kamikazi-0.5.0.ver ]; then
        touch /isodevice/kamikazi-0.5.0.ver
        echo "post-update: Touched kamikazi 0.5.0 version file."
    fi

    ## Print which image version was found.
    if [ ! -f /isodevice/kamikazi-0.4.0.ver ]; then
        echo "post-update: This is Disk Image version 0.4.0."
    fi
    if [ ! -f /isodevice/kamikazi-0.5.0.ver ]; then
        echo "post-update: This is Disk Image version 0.5.0."
    fi

    ### Finally, we need to ensure any optional icons are populated if they're needed.

    ## Check to see if the root-terminal icon exists. If not, make it.
    if [ ! -f /home/ubuntu/Desktop/root-terminal.desktop ]; then
        cp /home/git/zurfa-deploy/shortcuts/root-terminal.desktop /home/ubuntu/Desktop/
        chown 999:999 /home/ubuntu/Desktop/root-terminal.desktop
        echo "post-update: Added root-terminal icon."
    fi

    ## Check to see if the disker-terminal icon exists. If not, make it.
    if [ ! -f /home/ubuntu/Desktop/disker-terminal.desktop ]; then
        cp /home/git/zurfa-deploy/shortcuts/disker-terminal.desktop /home/ubuntu/Desktop/
        chown 999:999 /home/ubuntu/Desktop/disker-terminal.desktop
        echo "post-update: Added disker-terminal icon."
    fi


fi

echo "post-update: Nothing left to do."


