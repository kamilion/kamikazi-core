#!/bin/bash

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/zurfa-deploy/

# Deal with our repositories.
tools/pre-update.sh
tools/update-repos.sh
tools/post-update.sh
# Our repositories are up to date.
# Do any post-update installation scripts.
tools/pre-install.sh
tools/do-install.sh
tools/post-install.sh

