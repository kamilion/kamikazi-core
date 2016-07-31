#!/bin/bash

echo "kamikazi-ipmi: Searching for IPMI Board Management Controllers..."

# First load the message handler.
if modprobe ipmi_msghandler ; then
    echo "kamikazi-ipmi: Loaded IPMI message handler driver."
else
    echo "kamikazi-ipmi: IPMI Message handler driver failed to load."
fi

# Then load the dev interface to the device.
if modprobe ipmi_devintf ; then
    echo "kamikazi-ipmi: Loaded IPMI Device Interface driver."
else
    echo "kamikazi-ipmi: No IPMI Device Interface found or driver failed to load."
fi

# Then load the IPMI System Interface.
if modprobe ipmi_si ; then
    echo "kamikazi-ipmi: Loaded IPMI System Interface driver."
else
    echo "kamikazi-ipmi: No IPMI System Interface found or driver failed to load."
fi

echo "kamikazi-ipmi: IPMI System Interface information:"
# Get the IPMI interface's device information.
ipmitool mc info

echo "kamikazi-ipmi: IPMI Network Interface information:"
# Get the IPMI interface's network information.
ipmitool lan print

# Okay, we should have succeeded in loading zero or more of the SAS drivers.
echo "kamikazi-ipmi: Board Management Controller initialization complete..."

# Keep supervisord from complaining this job is too short.
sleep 3
echo "kamikazi-ipmi: Nothing left to do."
