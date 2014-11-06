#!/bin/bash

# V0.5.0 uses this from supervisor or serf triggered deploys.

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/

# Deal with our repositories.
kamikazi-deploy/tools/pre-update.sh
kamikazi-deploy/tools/update-repos.sh
kamikazi-deploy/tools/post-update.sh
# Our repositories are up to date.
# Do any post-update installation scripts.
kamikazi-deploy/tools/pre-install.sh
kamikazi-deploy/tools/do-install.sh
kamikazi-deploy/tools/post-install.sh

