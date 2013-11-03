#!/bin/bash

# V0.5.0 uses this instead of post-boot.sh

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/

# Deal with our repositories.
zurfa-deploy/tools/pre-update.sh
zurfa-deploy/tools/update-repos.sh
zurfa-deploy/tools/post-update.sh
# Our repositories are up to date.
# Do any post-update installation scripts.
zurfa-deploy/tools/pre-install.sh
zurfa-deploy/tools/do-install.sh
zurfa-deploy/tools/post-install.sh

