#!/bin/bash

# Check to see if the disker-terminal icon exists. If not, make it.
if [ ! -f /home/ubuntu/Desktop/disker-terminal.desktop ]; then
    cp shortcuts/disker-terminal.desktop /home/ubuntu/Desktop/
    chown 999:999 /home/ubuntu/Desktop/disker-terminal.desktop
fi

echo "post-update: Nothing to do."


