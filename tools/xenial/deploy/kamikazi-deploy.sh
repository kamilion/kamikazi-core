#!/bin/bash

# V0.8.0 uses this from supervisor or serf triggered deploys.

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/

# Deal with our repositories.
kamikazi-core/tools/latest/deploy/pre-update.sh
kamikazi-core/tools/latest/deploy/update-repos.sh
kamikazi-core/tools/latest/deploy/post-update.sh
# Our repositories are up to date.
# Do any post-update installation scripts.
kamikazi-core/tools/latest/deploy/pre-install.sh
kamikazi-core/tools/latest/deploy/do-install.sh
kamikazi-core/tools/latest/deploy/post-install.sh

