kamikazi-core
===============

This is a Xen livecd based on Lubuntu.

This repository is currently based on Lubuntu 16.04 and the systemd init system.

These are the xenial buildscripts.

To initiate a node as an isobuilder, run the setup-build-environment.sh as root.

To build the minilubuntu intermediary iso, run mini-rebuild.sh as root from within the buildscript directory.

To build the final kamikazi iso, run build.sh as root from within the buildscript directory.

After a successful build, subsequent iterations can be generated with rebuild.sh as root. This will not remove the workspace before building.

Running build.sh again will clean the workspace before rebuilding.

It is advised to fork this repository and modify autobuild-mini.customizer.hook.sh and autobuild.customizer.hook.sh to point at your own forked repository on github. Then your own repository changes will permanantly override your own builds. Check out how disker-gui is retrieved for an example on how to include your own git repos!
