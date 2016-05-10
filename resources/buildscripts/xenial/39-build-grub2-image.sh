#!/bin/bash

echo "[kamikazi-build] Building early boot xen grub2 images from grub-xen-bin package..."

OLDDIR=${PWD}

mkdir -p /tmp/grub-early/
cd /tmp/grub-early/

# To work around BITS's multiboot failing to load xen, we'll build a binary.
# Then we'll get BITS to load the binary instead.
# Note: 'search' and 'if' are only available in the 'normal' grub interpreter.
echo "[kamikazi-build] Creating inner grub.cfg..."
cat > "/tmp/grub-early/grub.cfg" <<EOF
# Allow overriding this inner grub2 with a kamikazi xengrub config file
if search -s -f /boot/config/xengrub.cfg ; then
        echo "Reading (${root})/boot/config/xengrub.cfg"
        configfile /boot/config/xengrub.cfg
fi

if search -s -f /boot/grub/xengrub.cfg ; then
        echo "Reading (${root})/boot/grub/xengrub.cfg"
        configfile /boot/grub/xengrub.cfg
fi

# Did not find an override file, dip into the ISO and boot xen.
# To override this, copy the following into one of the above paths.
if search -s -f /boot/isos/kamikazi-amd64-16.04.iso ; then
        echo "Found kamikazi-amd64 ISO, trying to load xen with kamikazi defaults."
        set isofile="/boot/isos/kamikazi-amd64-16.04.iso"
        loopback loop $isofile
        set gfxpayload=keep
        multiboot (loop)/casper/xen-4.6-amd64.gz loglvl=all guest_loglvl=all cpuinfo tsc=unstable dom0_mem=4G dom0_max_vcpus=32
        module (loop)/casper/vmlinuz.efi boot=casper iso-scan/filename=$isofile console=hvc0,115200 console=tty0 earlyprintk=xen noprompt libata.ignore_hpa=1 nodmraid raid=noautodetect ip=frommedia TORAM=Yes --
        module --nounzip (loop)/casper/initrd.lz
        boot
fi

EOF
echo "[kamikazi-build] Tarring inner grub.cfg in a memdisk.tar..."
tar cf memdisk.tar grub.cfg
rm -f /tmp/grub-early/grub.cfg
echo "[kamikazi-build] Creating outer grub.cfg..."
# This will load the above inner grub.cfg using the 'normal' interpreter, 
# instead of the minimal one available at early boot, which should chainload.
echo -e "normal (memdisk)/grub.cfg\n" > "/tmp/grub-early/grub.cfg"
mkdir -p /usr/lib/xen-4.6/boot/
cat > /tmp/grub-early/modlist.cfg <<EOF
normal linux linux16 loopback search ntldr ntfscomp freedos usbserial_usbdebug usb_keyboard usbms btrfs tar multiboot multiboot2 http efiemu xnu gfxmenu all_video biosdisk blocklist bsd cat cbfs cbls cbmemc cbtable cbtime cmosdump cmostest cmp configfile cpio_be cpio crc64 datehook date dm_nv drivemap echo ehci eval exfat ext2 fat file font gfxterm_background gfxterm_menu gfxterm gptsync gzio halt hashsum hdparm hexdump hwmatch iorw iso9660 jpeg keylayouts keystatus ldm loadenv lsacpi lsmmap ls lspci lvm lzopio memdisk memrw msdospart nativedisk newc nilfs2 odc ohci part_bsd parttool pata pcidump play png probe procfs progress pxechain pxe raid5rec raid6rec read reboot regexp romfs sendkey setjmp setpci sleep squash4 syslinuxcfg terminfo tftp tga time tr true udf uhci usbserial_ftdi usbserial_pl2303 vga_text videoinfo videotest xfs xzio
EOF
echo "[kamikazi-build] Building grub-i386-pc-isoxen.bin..."
grub-mkimage -v -O i386-pc -c grub.cfg -m memdisk.tar -o grub-i386-pc-isoxen.bin $(cat /tmp/grub-early/modlist.cfg)
echo "[kamikazi-build] Copying to /usr/lib/xen-4.6/boot/grub-i386-pc-isoxen.bin..."
cp grub-i386-pc-isoxen.bin /usr/lib/xen-4.6/boot/grub-i386-pc-isoxen.bin
echo "[kamikazi-build] Cleaning up..."
cd /tmp
rm -Rf /tmp/grub-early/

cd ${OLDDIR}

echo "[kamikazi-build] Built early boot xen grub2 image at /usr/lib/xen-4.6/boot/"
