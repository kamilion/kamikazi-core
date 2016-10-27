#!/bin/bash

echo "##################################"
echo "# KAMIKAZI ISO BUILD SCRIPT V0.7 #"
echo "##################################"
echo ""

# Disable dash as the default noninteractive shell, we have too many bashisms.
echo "[KAMIKAZI] Disabling dash as the default noninteractive shell..."
echo "set dash/sh false" | debconf-communicate

# Disable the eject prompt permanantly, we probably want rebooting to work
echo "[KAMIKAZI] Disabling CD Eject prompt."
sed -i 's,    # XXX - i18n,    # Disabled-by-kamilion\n    return 0\n\n&,g' /etc/init.d/casper

# Enable ipv4 forwarding in sysctl
echo "[KAMIKAZI] Enabling IPv4 forwarding in sysctl."
sed -i 's,#net.ipv4.ip_forward=1,net.ipv4.ip_forward=1,g' /etc/sysctl.conf
sysctl -p

# Either lubuntu-mini was used or we're doing a fresh rebuild
# Here are the packages we expect:
# wajig 

# Update repo database from wajig
echo "[KAMIKAZI] Updating repositories..."
wajig update

# Tell wajig to install stuff
echo "[KAMIKAZI] Installing git and etckeeper..."
wajig install -y git etckeeper

# Set up git's name and email for the commits to take effect
echo "[KAMIKAZI] Configuring git..."
git config --global user.email "ubuntu@sllabs.com"
git config --global user.name "Ubuntu Live CD"

echo "[KAMIKAZI] Configuring etckeeper..."
# Disable bzr in etckeeper
sed -i 's,VCS="bzr",#VCS="bzr",g' /etc/etckeeper/etckeeper.conf 
# Enable git in etckeeper
sed -i 's,#VCS="git",VCS="git",g' /etc/etckeeper/etckeeper.conf 

# Tell etckeeper to create it's git repository and populate it.
echo "[KAMIKAZI] Initializing etckeeper..."
etckeeper init


# Pull down core admin tools
echo "[KAMIKAZI] Installing core admin tools..."
wajig install -y software-properties-common python-software-properties screen byobu htop iftop iotop

# Pull down core networking tools
echo "[KAMIKAZI] Installing core network tools..."
wajig install -y ebtables

# Pull down python development tools
echo "[KAMIKAZI] Installing the required environment for pip to build binaries for python..."
wajig install -y python-dev python-pip

# Install the hypervisor itself
echo "[KAMIKAZI] Installing Xen..."
wajig install -y xen-system-amd64

# Put our xen defaults in place
echo "[KAMIKAZI] Configuring Xen bootloader defaults..."
sed -r 's/#XEN_OVERRIDE_GRUB_DEFAULT=0/XEN_OVERRIDE_GRUB_DEFAULT=1/g' -i /etc/default/grub.d/xen.cfg
sed -r 's/#GRUB_CMDLINE_XEN_DEFAULT=""/GRUB_CMDLINE_XEN_DEFAULT="loglvl=all guest_loglvl=all cpuinfo tsc=unstable"/g' -i /etc/default/grub.d/xen.cfg
sed -r 's/#GRUB_CMDLINE_XEN=""/GRUB_CMDLINE_XEN="dom0_mem=3G com2=115200,8n1 console=com2"/g' -i /etc/default/grub.d/xen.cfg
sed -r 's/#GRUB_CMDLINE_LINUX_XEN_REPLACE_DEFAULT="\$GRUB_CMDLINE_LINUX_DEFAULT"/GRUB_CMDLINE_LINUX_XEN_REPLACE_DEFAULT="console=hvc0,115200 earlyprintk=xen"/g' -i /etc/default/grub.d/xen.cfg

# We no longer need to go out to the internet for this, yay 14.10
#curl files.sllabs.com/files/storage/xen/xengrub.txt >> /etc/default/grub
# Trigger the actual bootloader update.
update-grub

# Ask pip to install the core python modules we need into the root system.
echo "[KAMIKAZI] Installing required python modules from pip..."
pip install sh netaddr uwsgi supervisor

# Make sure the annoying zram-by-default behavior of 14.04+ is off
echo "[KAMIKAZI] Making sure the bane of gnome-disks-tool known as zram-config is disabled..."
wajig purge -y zram-config

# Verify we have the packages we want
echo "[KAMIKAZI] Installing required packages if missing..."
wajig install -y ethtool dc3dd chrony ipmitool libatasmart-bin jq nodejs-legacy npm nginx
wajig install -y sdparm redis-server zenmap ceph

# Without this package, we'll get eth0 and friends
echo "[KAMIKAZI] Making sure ethernet devices have sane device naming..."
wajig install -y biosdevname

# Install RethinkDB from their Repo
echo "[KAMIKAZI] Installing RethinkDB..."
#source /etc/lsb-release && echo "deb http://download.rethinkdb.com/apt $DISTRIB_CODENAME main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
# Pull the trusty version of the package for now, until 1.15.2+ is released
source /etc/lsb-release && echo "deb http://download.rethinkdb.com/apt trusty main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
wget -qO- http://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add -
wajig update
wajig install -y rethinkdb
pip install rethinkdb

# Install openssh-server for X2go
echo "[KAMIKAZI] Installing openssh-server..."
wajig install -y openssh-server 
echo "[KAMIKAZI] Removing generated openssh-server host keys..."
rm -f /etc/ssh/ssh_host_*

# Install X2go from the stable ppa
echo "[KAMIKAZI] Installing X2go..."
wajig addrepo ppa:x2go/stable
wajig update
wajig install -y x2goserver x2goserver-xsession x2golxdebindings

# Install whdd from Kamilion's ppa
echo "[KAMIKAZI] Installing whdd..."
wajig addrepo ppa:kamilion/whdd
wajig update
wajig install -y whdd

# Install whdd from Kamilion's ppa
echo "[KAMIKAZI] Installing ubuntu-builder..."
wajig addrepo ppa:kamilion/ubuntu-builder
wajig update
wajig install -y whdd


echo "##############################################################"
echo "#All done, you can execute the next script and build the ISO.#"
echo "##############################################################"


