#!/bin/bash

echo "[kamikazi-build] Building 64bit pvgrub2 image from grub-xen-bin..."

OLDDIR=${PWD}

mkdir -p /tmp/grub/
cd /tmp/grub/

# Try debian's, then XENPV specification, then fall back to reading the .cfg
# Note: 'search' and 'if' are only available in the 'normal' grub interpreter.
echo "[kamikazi-build] Creating inner grub.cfg..."
cat > "/tmp/grub/grub.cfg" <<EOF
if search -s -f /usr/lib/grub-xen/grub-x86_64-xen.bin ; then
        echo "Chainloading (${root})/usr/lib/grub-xen/grub-x86_64-xen.bin"
        multiboot "/usr/lib/grub-xen/grub-x86_64-xen.bin"
        boot
fi

if search -s -f /boot/xen/pvboot-x86_64.elf ; then
        echo "Chainloading (${root})/boot/xen/pvboot-x86_64.elf"
        multiboot "/boot/xen/pvboot-x86_64.elf"
        boot
fi

if search -s -f /xen/pvboot-x86_64.elf ; then
        echo "Chainloading (${root})/xen/pvboot-x86_64.elf"
        multiboot "/xen/pvboot-x86_64.elf"
        boot
fi

if search -s -f /boot/grub/grub.cfg ; then
        echo "Reading (${root})/boot/grub/grub.cfg"
        configfile /boot/grub/grub.cfg
fi

if search -s -f /grub/grub.cfg ; then
        echo "Reading (${root})/grub/grub.cfg"
        configfile /grub/grub.cfg
fi
EOF
echo "[kamikazi-build] Tarring inner grub.cfg in a memdisk.tar..."
tar cf memdisk.tar grub.cfg
rm -f /tmp/grub/grub.cfg
echo "[kamikazi-build] Creating outer grub.cfg..."
# This will load the above inner grub.cfg using the 'normal' interpreter, 
# instead of the minimal one available at early boot, which should chainload.
echo -e "normal (memdisk)/grub.cfg\n" > "/tmp/grub/grub.cfg"
echo "[kamikazi-build] Building grub-x86_64-xen.bin..."
grub-mkimage -O x86_64-xen -c grub.cfg -m memdisk.tar -o grub-x86_64-xen.bin /usr/lib/grub/x86_64-xen
echo "[kamikazi-build] Copying to /usr/lib/xen-4.5/boot/grub-x86_64-xen.bin..."
cp grub-x86_64-xen.bin /usr/lib/xen-4.5/boot/grub-x86_64-xen.bin
echo "[kamikazi-build] Cleaning up..."
cd /tmp
rm -Rf /tmp/grub/
rmdir /tmp/grub

cd ${OLDDIR}

echo "[kamikazi-build] Built 64bit pvgrub2 image at /usr/lib/xen-4.5/boot/"
