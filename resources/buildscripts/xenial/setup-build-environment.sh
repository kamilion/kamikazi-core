#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else

  echo "[kamikazi-build] Setting this node up to be an ISO builder..."
  apt-get install --no-install-recommends -y git gksu build-essential fakeroot make binutils g++ python python-dev python-qt4 python3-pyqt4 pyqt4-dev-tools squashfs-tools xorriso x11-xserver-utils xserver-xephyr qemu-kvm dpkg-dev debhelper qt4-dev-tools qt4-linguist-tools 
  mkdir -p /home/kamikazi-16.04/
  mkdir -p /home/minilubuntu/
  ./10-add-iso-customizer.sh

  # Might wanna comment this out if you're not doing this from lubuntu.
  # I havn't tested it on xubuntu, gnome-desktop, KDE, or Unity.
  cp ../../latest/mods/usr/share/applications/customizer.desktop /usr/share/applications/customizer.desktop

  echo "[kamikazi-build] This node is now an ISO builder."
  echo "[kamikazi-build] Open a terminal, navigate to this directory."
  echo "[kamikazi-build] First run mini-rebuild.sh then build.sh."
  echo "[kamikazi-build] Then after at least one run of build.sh,"
  echo "[kamikazi-build] rebuild.sh can be used for faster rerolls."
  echo "[kamikazi-build] You can also run customizer-gui from a root terminal."

fi
