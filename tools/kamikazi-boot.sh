#!/bin/bash

# V0.5.0 uses this instead of post-boot.sh

btrfs device scan  # Assemble any btrfs arrays early.

touch /tmp/kamikazi-boot.stamp

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/

# Deal with updating our repositories.
supervisorctl start kamikazi-deploy

sleep 60

supervisorctl start kamikazi-boot-late


# kamikazi-deploy/tools/kamikazi-deploy.sh

