#!/bin/bash

# Earlier versions than 0.5.0 will run this on boot.

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

# No longer applies to 0.4.x but commenting it out will have no effect
#  since bash is already running the old version of this from the media.
#kamikazi-deploy/tools/post-install.sh

