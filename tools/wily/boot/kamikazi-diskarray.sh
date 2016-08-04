#!/bin/bash

echo "kamikazi-diskarrays: Searching for disk array devices..."

HBATYPE=""

load_3w_97xx() {
    HBATYPE="3ware"
    echo "kamikazi-diskarrays: Loading 3Ware 97XX driver."
    modprobe 3w-sas
    return $?
}

load_3w_96xx() {
    HBATYPE="3ware"
    echo "kamikazi-diskarrays: Loading 3Ware 96XX driver."
    modprobe 3w_9xxx
    return $?
}

load_lsisas3() {
    HBATYPE="lsisas3"
    echo "kamikazi-diskarrays: Loading LSI SAS3 driver."
    modprobe mpt3sas
    return $?
}

load_lsisas2() {
    HBATYPE="lsisas2"
    echo "kamikazi-diskarrays: Loading LSI SAS2 driver."
    modprobe mpt2sas
    return $?
}

load_lsisas1() {
    HBATYPE="lsisas1"
    echo "kamikazi-diskarrays: Loading LSI SAS1 driver."
    modprobe mptsas
    return $?
}


# Just try the drivers we blacklisted for now, in descending order.

# 3Ware/Areca
# Try 3Ware 97XX series first.
if [[ ! -z $(lspci -d 13c1:1010) ]]; then load_3w_97xx; fi
if [[ ! -z $(lspci -d 13c1:) ]]; then load_3w_97xx; fi

# Try 3Ware 96XX series second.
if [[ ! -z $(lspci -d 13c1:1004) ]]; then load_3w_96xx; fi
if [[ ! -z $(lspci -d 13c1:) ]]; then load_3w_96xx; fi

# LSI/Avago
# Try LSI SAS3xxx first. (SAS3008/3118) -- Will also deal with 2XXX devices.
if [[ ! -z $(lspci -d 1000:0097) ]]; then load_lsisas3; fi  # LSI SAS 3008
if [[ ! -z $(lspci -d 1000:0080) ]]; then load_lsisas3; fi  # LSI SAS 2208
if [[ ! -z $(lspci -d 1000:0073) ]]; then load_lsisas3; fi  # LSI SAS 2008
if [[ ! -z $(lspci -d 1000:0072) ]]; then load_lsisas3; fi  # LSI SAS 2008
if [[ ! -z $(lspci -d 1000:005b) ]]; then load_lsisas3; fi  # LSI SAS 2118
if [[ ! -z $(lspci -d 1000:) ]]; then load_lsisas3; fi  # LSI SAS 3XXX/2XXX

# Try LSI SAS2xxx second. (SAS2008/2118) -- This is a noop if lsisas3 already got it.
if [[ ! -z $(lspci -d 1000:) ]]; then load_lsisas2; fi  # LSI SAS 2XXX (older)

# Then try LSI SAS1xxx last. (SAS1068/1068E)
if [[ ! -z $(lspci -d 1000:0050) ]]; then load_lsisas1; fi  # LSI SAS1068E
if [[ ! -z $(lspci -d 1000:0054) ]]; then load_lsisas1; fi  # LSI SAS1068
if [[ ! -z $(lspci -d 1000:0056) ]]; then load_lsisas1; fi  # LSI SAS1064ET
if [[ ! -z $(lspci -d 1000:0058) ]]; then load_lsisas1; fi  # LSI SAS1068E
if [[ ! -z $(lspci -d 1000:005e) ]]; then load_lsisas1; fi  # LSI SAS1066

# Okay, we should have succeeded in loading zero or more of the SAS drivers.
echo "kamikazi-diskarrays: ${HBATYPE} disk array initialization complete..."

# Keep supervisord from complaining this job is too short.
sleep 3
echo "kamikazi-diskarrays: Nothing left to do."
