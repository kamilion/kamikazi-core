#!/bin/bash
echo "KAMIKAZI-REBUILD: Cleaning up previous run..."
customizer -t
echo "KAMIKAZI-REBUILD: Extracting ISO..."
customizer -e
echo "KAMIKAZI-REBUILD: Triggering custom hook..."
customizer -k
echo "KAMIKAZI-REBUILD: Fixing xen on ISO..."
cp -f /home/ubuntu/git/kamikazi-core/resources/buildscripts/wily/isomods/* /home/kamikazi-15.10/ISO/isolinux/
echo "KAMIKAZI-REBUILD: Removing WUBI from ISO..."
rm -f /home/kamikazi-15.10/ISO/wubi.exe
rm -f /home/kamikazi-15.10/ISO/autorun.inf
rm -Rf /home/kamikazi-15.10/ISO/pics/
echo "KAMIKAZI-REBUILD: Removing package pool from ISO..."
rm -Rf /home/kamikazi-15.10/ISO/dists/
rm -Rf /home/kamikazi-15.10/ISO/pool/
echo "KAMIKAZI-REBUILD: Clearing annoyances from filesystem..."
rm -Rf /home/kamikazi-15.10/FileSystem/var/cache/apt/archives
mkdir -p /home/kamikazi-15.10/FileSystem/var/cache/apt/archives/partial
echo "KAMIKAZI-REBUILD: Clearing apport crash reports from filesystem..."
rm -f /home/kamikazi-15.10/FileSystem/var/crash/*
echo "KAMIKAZI-REBUILD: Building output ISO..."
customizer -r
echo "KAMIKAZI-REBUILD: Complete."
exit 0

