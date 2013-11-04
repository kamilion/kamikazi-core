#!/bin/bash

# V0.5.0 uses this to shut down.

MYNAME=$(hostname)
echo -n "zurfa-shutdown: We are: ${MYNAME}"

if [ "${1}" == "all" ]; then
  shutdown -h ${2:-1}
fi
if [ "${1}" == "${MYNAME}" ]; then
  shutdown -h ${2:-1}
fi

