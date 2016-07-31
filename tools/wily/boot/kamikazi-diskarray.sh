#!/bin/bash

echo "kamikazi-diskarrays: Searching for disk array devices..."

# Just try the drivers we blacklisted for now, in descending order.
if modprobe 3w_9xxx ; then
    echo "kamikazi-diskarrays: Loaded 3Ware 9XXX driver."
else
    echo "kamikazi-diskarrays: No 3Ware 9XXX found or driver failed to load."
fi

# Try LSI SAS3xxx first. (SAS3008/3118)
if modprobe mpt3sas ; then
    echo "kamikazi-diskarrays: Loaded LSI SAS3xxx driver."
else
    echo "kamikazi-diskarrays: No LSI SAS3xxx found or driver failed to load."
fi

# Try LSI SAS2xxx second. (SAS2008/2118)
if modprobe mpt2sas ; then
    echo "kamikazi-diskarrays: Loaded LSI SAS2xxx driver."
else
    echo "kamikazi-diskarrays: No LSI SAS2xxx found or driver failed to load."
fi

# Then try LSI SAS1xxx last. (SAS1068/1068E)
if modprobe mptsas ; then
    echo "kamikazi-diskarrays: Loaded LSI SAS1xxx driver."
else
    echo "kamikazi-diskarrays: No LSI SAS1xxx found or driver failed to load."
fi

# Okay, we should have succeeded in loading zero or more of the SAS drivers.
echo "kamikazi-diskarrays: disk array initialization complete..."

# Keep supervisord from complaining this job is too short.
sleep 3
echo "kamikazi-diskarrays: Nothing left to do."
