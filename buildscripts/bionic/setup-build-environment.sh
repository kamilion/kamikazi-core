#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else

  echo "[kamikazi-build] Setting this node up to be an ISO builder..."
  apt-get install --no-install-recommends -y git gksu build-essential fakeroot make binutils g++ squashfs-tools xorriso x11-xserver-utils xserver-xephyr qemu-kvm dpkg-dev debhelper 
  apt-get install --no-install-recommends -y python python-dev python-qt5 
  apt-get install --no-install-recommends -y python3 python3-dev python3-pyqt5 pyqt5-dev-tools qttools5-dev-tools qt5-default
  mkdir -p /home/kamikazi-18.04/
  mkdir -p /home/minilubuntu/
  ./19-add-iso-customizer.sh

  # Might wanna comment this out if you're not doing this from lubuntu.
  # I havn't tested it on xubuntu, gnome-desktop, KDE, or Unity.
  #cp ../../latest/mods/usr/share/applications/customizer.desktop /usr/share/applications/customizer.desktop
  # -- No longer needed, fixed this when I took over the Customizer project.

  echo "[kamikazi-build] This node is now an ISO builder."
  echo "[kamikazi-build] Open a terminal, navigate to this directory."
  echo "[kamikazi-build] First run mini-rebuild.sh then build.sh."
  echo "[kamikazi-build] Then after at least one run of build.sh,"
  echo "[kamikazi-build] rebuild.sh can be used for faster rerolls."
  echo "[kamikazi-build] You can also run customizer-gui from a root terminal."

fi
