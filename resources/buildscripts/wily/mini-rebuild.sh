#!/bin/bash
cp customizer-mini.conf /etc/customizer.conf
echo "KAMIKAZI-REBUILD: Cleaning up previous run..."
customizer -t
echo "KAMIKAZI-REBUILD: Extracting ISO..."
customizer -e
echo "KAMIKAZI-REBUILD: Triggering custom hook..."
customizer -k
echo "KAMIKAZI-REBUILD: Removing WUBI from ISO..."
rm -f /home/minilubuntu/ISO/wubi.exe
rm -f /home/minilubuntu/ISO/autorun.inf
rm -Rf /home/minilubuntu/ISO/pics/
echo "KAMIKAZI-REBUILD: Removing package pool from ISO..."
rm -Rf /home/minilubuntu/ISO/dists/
rm -Rf /home/minilubuntu/ISO/pool/
echo "KAMIKAZI-REBUILD: Clearing annoyances from filesystem..."
rm -Rf /home/minilubuntu/FileSystem/home/git
rm -Rf /home/minilubuntu/FileSystem/var/cache/apt/archives
mkdir -p /home/minilubuntu/FileSystem/var/cache/apt/archives/partial
echo "KAMIKAZI-REBUILD: Clearing apport crash reports from filesystem..."
rm -f /home/minilubuntu/FileSystem/var/crash/*
#echo "KAMIKAZI-REBUILD: Building output ISO..."
#customizer -r
echo "KAMIKAZI-REBUILD: Complete."
exit 0

