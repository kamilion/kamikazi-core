#!/bin/bash

# V0.5.0 uses this instead of post-boot.sh

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/

# Deal with updating our repositories.
supervisorctl start zurfa-deploy

sleep 60

supervisorctl start zurfa-boot-late


# zurfa-deploy/tools/zurfa-deploy.sh

