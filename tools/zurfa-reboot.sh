#!/bin/bash

# V0.5.0 uses this to reboot.

MYNAME=$(hostname)
echo -n "zurfa-shutdown: We are: ${MYNAME}"

if [ "${1}" == "all" ]; then
  shutdown -r ${2:-1}
fi
if [ "${1}" == "${MYNAME}" ]; then
  shutdown -r ${2:-1}
fi

